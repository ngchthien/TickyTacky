//
//  BotEngineService.swift
//  TickyTacky
//
//  Created by M1 Pro on 11/4/26.
//

import Foundation

protocol BotEngineServiceProtocol {
    func bestMove(in board: Board, difficulty: Difficulty) -> CellCoordinate
}

struct BotEngineService: BotEngineServiceProtocol {
    func bestMove(in board: Board, difficulty: Difficulty) -> CellCoordinate {
        switch difficulty {
        case .easy:
            return randomMove(from: board)
        case .medium:
            return mediumMove(from: board)
        case .hard:
            // Placeholder for optimal move logic (Minimax)
            return .init(row: 0, col: 0)
        }
    }
}

private extension BotEngineService {
    func randomMove(from board: Board) -> CellCoordinate {
        let emptyCells: [CellCoordinate] = board.enumerated().flatMap { rowIndex, row in
            row.enumerated().compactMap { colIndex, cell in
                cell == .empty ? CellCoordinate(row: rowIndex, col: colIndex) : nil
            }
        }
        
        return emptyCells.randomElement() ?? CellCoordinate(row: 0, col: 0)
    }
    
    func mediumMove(from board: Board) -> CellCoordinate {
        if let winningMove = immediateWinningMove(for: .o, in: board) {
            return winningMove
        }
        
        if let blockMove = immediateWinningMove(for: .x, in: board) {
            return blockMove
        }
        
        return randomMove(from: board)
    }
    
    func immediateWinningMove(for player: CellState, in board: Board) -> CellCoordinate? {
        for row in 0..<3 {
            for col in 0..<3 {
                if board[row][col] == .empty {
                    var tempBoard = board
                    tempBoard[row][col] = player
                    if checkWinner(in: tempBoard) == player {
                        return CellCoordinate(row: row, col: col)
                    }
                }
            }
        }
        return nil
    }
    
    func checkWinner(in board: Board) -> CellState? {
        let lines = [
            [(0,0), (0,1), (0,2)],
            [(1,0), (1,1), (1,2)],
            [(2,0), (2,1), (2,2)],
            [(0,0), (1,0), (2,0)],
            [(0,1), (1,1), (2,1)],
            [(0,2), (1,2), (2,2)],
            [(0,0), (1,1), (2,2)],
            [(0,2), (1,1), (2,0)]
        ]
        
        for line in lines {
            let (a,b,c) = (line[0], line[1], line[2])
            let values = [board[a.0][a.1], board[b.0][b.1], board[c.0][c.1]]
            if values.allSatisfy({ $0 == .x }) { return .x }
            if values.allSatisfy({ $0 == .o }) { return .o }
        }
        
        return board.flatMap { $0 }.contains(.empty) ? nil : .empty
    }
}
