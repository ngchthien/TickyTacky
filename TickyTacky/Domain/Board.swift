//
//  Board.swift
//  TickyTacky
//
//  Created by M1 Pro on 11/4/26.
//

import Foundation

typealias Board = [[CellState]]

extension Board {
    static var empty: Self {
        .init(repeating: .init(repeating: .empty, count: GameConstants.boardSize), count: GameConstants.boardSize)
    }
}
