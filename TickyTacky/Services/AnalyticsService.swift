//
//  AnalyticsService.swift
//  TickyTacky
//
//  Created by M1 Pro on 11/4/26.
//

import Foundation

protocol AnalyticsProtocol {
    func trackGameStart(difficulty: Difficulty, firstTurn: FirstTurn)
    func trackMove(player: PlayerType, position: CellCoordinate)
    func trackGameEnd(result: GameResult)
    func trackError(_ error: GameError)
}

final class AnalyticsService: AnalyticsProtocol {
    func trackGameStart(difficulty: Difficulty, firstTurn: FirstTurn) {
        print("📊 Analytics: Game Started | Difficulty: \(difficulty) | First Turn: \(firstTurn)")
    }
    
    func trackMove(player: PlayerType, position: CellCoordinate) {
        print("📊 Analytics: Move | Player: \(player) | Position: (\(position.row), \(position.col))")
    }
    
    func trackGameEnd(result: GameResult) {
        print("📊 Analytics: Game Ended | Result: \(result)")
    }
    
    func trackError(_ error: GameError) {
        print("📊 Analytics: Error | \(error.localizedDescription)")
    }
}
