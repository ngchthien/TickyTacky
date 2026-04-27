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
    @Published var error: GameError?
    
    private var gameStartDate: Date?
    
    @Injected(\.appModeStore) var appModeStore
    @Injected(\.gameStore) var gameStore
    @Injected(\.errorHandlerService) var errorHandlerService
    @Injected(\.analyticsService) var analyticsService
    @Injected(\.hapticService) var hapticService
    @Injected(\.historyService) var historyService
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
        playMove(row: row, col: col)
    }
    
  
}

private extension GameViewModel {
    func gameSetup() {
        let currentPlayer = getFirstTurnPlayer()
        self.currentPlayer = currentPlayer
        self.nextStartingPlayer = currentPlayer
        self.gameStartDate = Date()
        
        analyticsService.trackGameStart(difficulty: difficulty, firstTurn: gameSetupStore.selectedFirstTurn)
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
            
            let bestMove = gameStore.botBestMove(in: board, difficulty: difficulty, botSymbol: currentPlayer.cellSymbol)
            playMove(row: bestMove.row, col: bestMove.col)
        }
    }
    
    func playMove(row: Int, col: Int) {
        do {
            try gameStore.validateMove(row: row, col: col, board: board, gameState: gameState)
            
            withAnimation(.spring(duration: GameConstants.cellsAnimation)) {
                board[row][col] = currentPlayer.cellSymbol
            }
            
            
            hapticService.triggerImpact(style: .light)
            analyticsService.trackMove(player: currentPlayer.isBot ? .bot : .human, position: .init(row: row, col: col))
            
            if let winningCellCordinatesPath = gameStore.checkWin(in: board, for: currentPlayer.cellSymbol) {
                Task {
                    await animateWinningCellsPath(winningCellCordinatesPath)
                    handleGameEnd(winner: currentPlayer)
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
    
    func handleGameEnd(winner: Player?) {
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
            } else {
                hapticService.triggerNotification(type: .error)
            }
            
            analyticsService.trackGameEnd(result: winner.isBot ? .botWin : .humanWin)
        } else {
            nextStartingPlayer = otherPlayer
            transitionGameState(to: .tied)
            hapticService.triggerNotification(type: .warning)
            analyticsService.trackGameEnd(result: .tie)
        }
        
        saveGameToHistory(winner: winner)
    }
    
    func saveGameToHistory(winner: Player?) {
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
        
        historyService.saveMatch(history)
    }
    
    func handleError(_ error: GameError) {
        self.error = error
        errorHandlerService.handle(error)
        analyticsService.trackError(error)
    }
    
    func triggerTie() {
        Task {
            try? await Task.sleep(for: .seconds(GameConstants.gameOverDelay))
            handleGameEnd(winner: nil)
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

