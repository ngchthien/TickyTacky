//
//  GameViewModel.swift
//  TickyTacky
//
//  Created by M1 Pro on 12/4/26.
//

import Foundation
import Combine
import SwiftUI
import Factory

@MainActor
final class GameViewModel: ObservableObject {
    @Published var player1: Player
    @Published var player2: Player
    let difficulty: Difficulty
    
    @Published private(set) var gameState: GameState = .playing
    @Published var board: Board = .empty
    @Published var currentPlayer: Player = .defaultPlayer
    @Published var nextStartingPlayer: Player = .defaultPlayer
    @Published var isBotMovePending = false
    @Published var isAnimationInProgress = false
    @Published var winningCells: [CellCoordinate] = []
    @Published var suggestedMove: CellCoordinate?
    @Published var error: GameError?
    @Published var newAchievements: [Achievement] = []
    @Published var showConfetti: Bool = false
    
    private var gameStartDate: Date?
    private var moveCount: Int = 0
    @AppStorage("winStreak") private var winStreak: Int = 0
    
    @Injected(\.appModeStore) var appModeStore
    @Injected(\.gameStore) var gameStore
    @Injected(\.errorHandlerService) var errorHandlerService
    @Injected(\.analyticsService) var analyticsService
    @Injected(\.hapticService) var hapticService
    @Injected(\.historyService) var historyService
    @Injected(\.achievementService) var achievementService
    private let gameSetupStore = Container.shared.gameSetupStore()
    
    init() {
        player1 = .init(profile: gameSetupStore.player1, symbol: .x)
        player2 = .init(profile: gameSetupStore.player2, symbol: .o)
        difficulty = gameSetupStore.selectedDifficulty
        gameSetup()
        if currentPlayer.isBot {
            playBotMove()
        }
    }
    
    var isPlayHumanMoveDisabled: Bool {
        currentPlayer.isBot || isBotMovePending || isAnimationInProgress || gameState != .playing
    }
    
    var otherPlayer: Player {
        currentPlayer == player1 ? player2 : player1
    }
    
    var showWinnerSheet: Bool {
        gameState.isGameOver
    }
    
    func goSetupMode() {
        appModeStore.goSetupMode()
    }
    
    func resetGame() {
        withAnimation(.spring(duration: GameConstants.cellsAnimation)) {
            resetBoard()
            resetGameState()
            isBotMovePending = false
            isAnimationInProgress = false
            error = nil
            moveCount = 0
            newAchievements = []
            showConfetti = false
        }
        
        if currentPlayer.isBot {
            playBotMove()
        }
    }
    
    func fullReset() {
        resetGame()
        resetPlayerWins()
    }
    
    func playHumanMove(row: Int, col: Int) {
        guard !isPlayHumanMoveDisabled else { return }
        suggestedMove = nil
        playMove(row: row, col: col)
    }
    
    func getHint() {
        guard !isPlayHumanMoveDisabled else { return }
        
        Task {
            let bestMove = await gameStore.botBestMove(in: board, difficulty: .hard, botSymbol: currentPlayer.cellSymbol)
            
            withAnimation(.spring()) {
                suggestedMove = bestMove
            }
            
            hapticService.triggerImpact(style: .medium)
            
            // Auto-hide hint after 2 seconds
            try? await Task.sleep(for: .seconds(2))
            if suggestedMove == bestMove {
                withAnimation {
                    suggestedMove = nil
                }
            }
        }
    }
    
  
}

private extension GameViewModel {
    func gameSetup() {
        let currentPlayer = getFirstTurnPlayer()
        self.currentPlayer = currentPlayer
        self.nextStartingPlayer = currentPlayer
        self.gameStartDate = Date()
        self.moveCount = 0
        self.newAchievements = []
        
        analyticsService.trackGameStart(difficulty: difficulty.rawValue, firstTurn: gameSetupStore.selectedFirstTurn.rawValue)
    }
    
    func getFirstTurnPlayer() -> Player {
        switch gameSetupStore.selectedFirstTurn {
        case .you:
            return player1
        case .opponent:
            return player2
        case .random:
            return Bool.random() ? player1 : player2
        }
    }
    func playBotMove() {
        Task {
            isBotMovePending = true
            defer { isBotMovePending = false }
            
            try? await Task.sleep(for: .seconds(GameConstants.botMoveDelay))
            
            let bestMove = await gameStore.botBestMove(in: board, difficulty: difficulty, botSymbol: currentPlayer.cellSymbol)
            playMove(row: bestMove.row, col: bestMove.col)
        }
    }
    
    func playMove(row: Int, col: Int) {
        do {
            try gameStore.validateMove(row: row, col: col, board: board, gameState: gameState)
            
            withAnimation(.spring(duration: GameConstants.cellsAnimation)) {
                board[row][col] = currentPlayer.cellSymbol
                moveCount += 1
            }
            
            
            hapticService.triggerImpact(style: .light)
            
            if let winningCellCordinatesPath = gameStore.checkWin(in: board, for: currentPlayer.cellSymbol) {
                Task {
                    await animateWinningCellsPath(winningCellCordinatesPath)
                    await handleGameEnd(winner: currentPlayer)
                }
            } else if gameStore.isBoardFull(board) {
                triggerTie()
            } else {
                switchToNextPlayer()
            }
        } catch {
            handleError(error as? GameError ?? .invalidGameState)
        }
    }
}

private extension GameViewModel {
    func animateWinningCellsPath(_ path: [CellCoordinate]) async {
        isAnimationInProgress = true
        defer { isAnimationInProgress = false }
        
        for coordinate in path {
            winningCells.append(coordinate)
            try? await Task.sleep(for: .seconds(GameConstants.winningCellDelay))
        }
    }
    
    func handleGameEnd(winner: Player?) async {
        if let winner {
            if winner == player1 {
                player1.wins += 1
            } else {
                player2.wins += 1
            }
            nextStartingPlayer = winner
            transitionGameState(to: .won(winner))
            
            if !winner.isBot {
                hapticService.triggerNotification(type: .success)
                showConfetti = true
            } else {
                hapticService.triggerNotification(type: .error)
            }
            
            analyticsService.trackGameEnd(result: winner.isBot ? GameResult.botWin.rawValue : GameResult.humanWin.rawValue)
        } else {
            nextStartingPlayer = otherPlayer
            transitionGameState(to: .tied)
            hapticService.triggerNotification(type: .warning)
            analyticsService.trackGameEnd(result: GameResult.tie.rawValue)
        }
        
        await saveGameToHistory(winner: winner)
    }
    
    func saveGameToHistory(winner: Player?) async {
        guard let startDate = gameStartDate else { return }
        let duration = Date().timeIntervalSince(startDate)
        
        let resultType: String
        if let winner = winner {
            resultType = winner == player1 ? "Win" : "Loss"
        } else {
            resultType = "Tie"
        }
        
        let history = MatchHistory(
            player1Name: player1.profile.name.description,
            player2Name: player2.profile.name.description,
            winnerName: winner?.profile.name.description,
            duration: duration,
            difficulty: difficulty.description,
            resultType: resultType
        )
        
        await historyService.saveMatch(history)
        
        await checkAchievements(result: resultType == "Win" ? .humanWin : (resultType == "Loss" ? .botWin : .tie), duration: duration)
    }
    
    func checkAchievements(result: GameResult, duration: TimeInterval) async {
        if result == .humanWin {
            winStreak += 1
        } else if result == .botWin {
            winStreak = 0
        }
        
        let matches = await historyService.fetchAllMatches()
        let totalTies = matches.filter { $0.resultType == "Tie" }.count
        
        let unlocked = achievementService.checkAchievements(
            result: result,
            difficulty: difficulty,
            duration: duration,
            moveCount: moveCount,
            winStreak: winStreak,
            totalTies: totalTies
        )
        
        if !unlocked.isEmpty {
            withAnimation(.spring()) {
                newAchievements = unlocked
            }
            hapticService.triggerNotification(type: .success)
        }
    }
    
    func handleError(_ error: GameError) {
        self.error = error
        errorHandlerService.handle(error)
        analyticsService.trackError(error.localizedDescription)
    }
    
    func triggerTie() {
        Task {
            try? await Task.sleep(for: .seconds(GameConstants.gameOverDelay))
            await handleGameEnd(winner: nil)
        }
    }
    
    func switchToNextPlayer() {
        currentPlayer = otherPlayer
        if currentPlayer.isBot {
            playBotMove()
        }
    }
    
    func transitionGameState(to newState: GameState) {
        guard gameState != newState else { return }
        gameState = newState
    }
    
    func resetBoard() {
        board = .empty
        winningCells = []
    }
    
    func resetGameState() {
        currentPlayer = nextStartingPlayer
        transitionGameState(to: .playing)
    }
    
    func resetPlayerWins() {
        player1.wins = 0
        player2.wins = 0
    }
}

