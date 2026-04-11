//
//  GameError.swift
//  TickyTacky
//
//  Created by M1 Pro on 11/4/26.
//

import Foundation

enum GameError: Error {
    case invalidMove(row: Int, col: Int)
    case gameNotInProgress
    case botMoveFailure
    case invalidGameState
}

extension GameError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidMove(let row, let col):
            return "Invalid move at position (\(row), \(col))"
        case .gameNotInProgress:
            return "Game is not in progress"
        case .botMoveFailure:
            return "Bot failed to make a move"
        case .invalidGameState:
            return "Invalid game state"
        }
    }
}
