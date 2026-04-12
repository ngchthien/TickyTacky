//
//  BotEngineService.swift
//  TickyTacky
//
//  Created by M1 Pro on 11/4/26.
//

import Foundation

protocol BotEngineServiceProtocol {
    func bestMove(in board: Board, difficulty: Difficulty, botSymbol: CellState) -> CellCoordinate
}

struct BotEngineService: BotEngineServiceProtocol {
    func bestMove(in board: Board, difficulty: Difficulty, botSymbol: CellState) -> CellCoordinate {
        switch difficulty {
        case .easy:
            return randomMove(from: board)
        case .medium:
            return mediumMove(from: board, botSymbol: botSymbol)
        case .hard:
            return hardMove(from: board, botSymbol: botSymbol)
        }
    }
}

private extension BotEngineService {
    func hardMove(from board: Board, botSymbol: CellState) -> CellCoordinate {
        var bestScore = Int.min
        var move = CellCoordinate(row: 0, col: 0)
        let opponentSymbol: CellState = botSymbol == .x ? .o : .x
        
        for row in 0..<3 {
            for col in 0..<3 {
                if board[row][col] == .empty {
                    var tempBoard = board
                    tempBoard[row][col] = botSymbol
                    let score = minimax(board: tempBoard, depth: 0, isMaximizing: false, botSymbol: botSymbol, opponentSymbol: opponentSymbol)
                    if score > bestScore {
                        bestScore = score
                        move = CellCoordinate(row: row, col: col)
                    }
                }
            }
        }
        return move
    }
    
    func minimax(board: Board, depth: Int, isMaximizing: Bool, botSymbol: CellState, opponentSymbol: CellState) -> Int {
        let winner = checkWinner(in: board)
        if winner == botSymbol { return 10 - depth }
        if winner == opponentSymbol { return depth - 10 }
        if !board.flatMap({ $0 }).contains(.empty) { return 0 }
        
        if isMaximizing {
            var bestScore = Int.min
            for row in 0..<3 {
                for col in 0..<3 {
                    if board[row][col] == .empty {
                        var tempBoard = board
                        tempBoard[row][col] = botSymbol
                        let score = minimax(board: tempBoard, depth: depth + 1, isMaximizing: false, botSymbol: botSymbol, opponentSymbol: opponentSymbol)
                        bestScore = max(score, bestScore)
                    }
                }
            }
            return bestScore
        } else {
            var bestScore = Int.max
            for row in 0..<3 {
                for col in 0..<3 {
                    if board[row][col] == .empty {
                        var tempBoard = board
                        tempBoard[row][col] = opponentSymbol
                        let score = minimax(board: tempBoard, depth: depth + 1, isMaximizing: true, botSymbol: botSymbol, opponentSymbol: opponentSymbol)
                        bestScore = min(score, bestScore)
                    }
                }
            }
            return bestScore
        }
    }
    
    func randomMove(from board: Board) -> CellCoordinate {
        let emptyCells: [CellCoordinate] = board.enumerated().flatMap { rowIndex, row in
            row.enumerated().compactMap { colIndex, cell in
                cell == .empty ? CellCoordinate(row: rowIndex, col: colIndex) : nil
            }
        }
        
        return emptyCells.randomElement() ?? CellCoordinate(row: 0, col: 0)
    }
    
    func mediumMove(from board: Board, botSymbol: CellState) -> CellCoordinate {
        if let winningMove = immediateWinningMove(for: botSymbol, in: board) {
            return winningMove
        }
        
        let opponentSymbol: CellState = botSymbol == .x ? .o : .x
        if let blockMove = immediateWinningMove(for: opponentSymbol, in: board) {
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
