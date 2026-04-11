//
//  GameState.swift
//  TickyTacky
//
//  Created by M1 Pro on 11/4/26.
//

import Foundation

enum GameState: Equatable {
    case playing
    case won(Player)
    case tied
    
    var isGameOver: Bool {
        switch self {
        case .playing: return false
        case .won, .tied: return true
        }
    }
    
    var isTied: Bool {
        self == .tied
    }
    
    var winnerPlayer: Player? {
        switch self {
        case .won(let player): return player
        case .tied, .playing: return nil
        }
    }
}
