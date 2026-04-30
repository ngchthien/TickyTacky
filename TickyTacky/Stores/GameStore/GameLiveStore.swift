//
//  GameLiveStore.swift
//  TickyTacky
//
//  Created by M1 Pro on 11/4/26.
//

import Foundation
import Factory

final class GameLiveStore: GameStore {
    @Injected(\.boardLogicService) private var boardLogic
    @Injected(\.botEngineService) private var botEngine
    
    func validateMove(row: Int, col: Int, board: Board, gameState: GameState) throws {
        try boardLogic.validateMove(row: row, col: col, board: board, gameState: gameState)
    }
    
    func checkWin(in board: Board, for cellSymbol: CellState) -> [CellCoordinate]? {
        boardLogic.checkWin(in: board, for: cellSymbol)
    }
    
    func isBoardFull(_ board: Board) -> Bool {
        boardLogic.isBoardFull(board)
    }
    
    func botBestMove(in board: [[CellState]], difficulty: Difficulty, botSymbol: CellState) async -> CellCoordinate {
        await botEngine.bestMove(in: board, difficulty: difficulty, botSymbol: botSymbol)
    }
}
