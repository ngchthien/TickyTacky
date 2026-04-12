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
    
    @Injected(\.appModeStore) var appModeStore
    @Injected(\.gameStore) var gameStore
    @Injected(\.errorHandlerService) var errorHandlerService
    @Injected(\.analyticsService) var analyticsService
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
        isBotMovePending || isAnimationInProgress || gameState != .playing
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
        playMove(row: row, col: col)
    }
    
  
}

private extension GameViewModel {
    func gameSetup() {
        let currentPlayer = getFirstTurnPlayer()
        self.currentPlayer = currentPlayer
        self.nextStartingPlayer = currentPlayer
        
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
            
            let bestMove = gameStore.botBestMove(in: board, difficulty: difficulty)
            playMove(row: bestMove.row, col: bestMove.col)
        }
    }
    
    func playMove(row: Int, col: Int) {
        do {
            try gameStore.validateMove(row: row, col: col, board: board, gameState: gameState)
            
            withAnimation(.spring(duration: GameConstants.cellsAnimation)) {
                board[row][col] = currentPlayer.cellSymbol
            }
            
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
            analyticsService.trackGameEnd(result: winner.isBot ? .botWin : .humanWin)
        } else {
            nextStartingPlayer = otherPlayer
            transitionGameState(to: .tied)
            analyticsService.trackGameEnd(result: .tie)
        }
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

