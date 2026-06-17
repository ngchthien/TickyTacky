//
//  GameConstants.swift
//  TickyTacky
//
//  Created by M1 Pro on 11/4/26.
//

import Foundation

struct GameConstants {
    static let boardSize = 3
    static let botMoveDelay: Double = 0.4
    static let winningCellsAnimationDelay: Double = 0.4
    static let winningCellDelay: Double = 0.2
    static let cellsAnimation: Double = 0.4
    static let gameOverDelay: Double = 0.8
    
    // UI Constants
    static let boardSpacing: CGFloat = 12
    static let playerSwapAnimationDuration: Double = 0.35
    static let cellFontSize: CGFloat = 40
    static let winnerSheetHeight: CGFloat = 260
    
    static let winningLines: [[(Int, Int)]] = [
        [(0,0), (0,1), (0,2)],
        [(1,0), (1,1), (1,2)],
        [(2,0), (2,1), (2,2)],
        [(0,0), (1,0), (2,0)],
        [(0,1), (1,1), (2,1)],
        [(0,2), (1,2), (2,2)],
        [(0,0), (1,1), (2,2)],
        [(0,2), (1,1), (2,0)]
    ]
}
