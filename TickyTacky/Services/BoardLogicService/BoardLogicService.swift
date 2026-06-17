//
//  BoardLogicService.swift
//  TickyTacky
//
//  Created by M1 Pro on 11/4/26.
//

import Foundation

final class BoardLogicLiveService: BoardLogicServiceProtocol {
    func validateMove(row: Int, col: Int, board: Board, gameState: GameState) throws {
        guard row >= 0 && row < GameConstants.boardSize && col >= 0 && col < GameConstants.boardSize else {
            throw GameError.invalidMove(row: row, col: col)
        }
        
        guard gameState == .playing else {
            throw GameError.gameNotInProgress
        }
        
        guard board[row][col] == .empty else {
            throw GameError.invalidMove(row: row, col: col)
        }
    }
    
    func checkWin(in board: Board, for cellSymbol: CellState) -> [CellCoordinate]? {
        let lines = GameConstants.winningLines
        
        for line in lines {
            let cells = line.map { board[$0.0][$0.1] }
            if cells.allSatisfy({ $0 == cellSymbol }) {
                return line.map { CellCoordinate(row: $0.0, col: $0.1) }
            }
        }
        
        return nil
    }
    
    func isBoardFull(_ board: Board) -> Bool {
        !board.flatMap { $0 }.contains(.empty)
    }
}
