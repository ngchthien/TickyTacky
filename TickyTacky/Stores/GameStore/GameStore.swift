//
//  GameStore.swift
//  TickyTacky
//
//  Created by M1 Pro on 11/4/26.
//

import Foundation

protocol GameStore {
    func validateMove(row: Int, col: Int, board: Board, gameState: GameState) throws
    func checkWin(in board: Board, for cellSymbol: CellState) -> [CellCoordinate]?
    func isBoardFull(_ board: Board) -> Bool
    func botBestMove(in board: [[CellState]], difficulty: Difficulty) -> CellCoordinate
}
