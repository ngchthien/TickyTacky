//
//  PlayerName.swift
//  TickyTacky
//
//  Created by M1 Pro on 7/4/26.
//

import Foundation

enum PlayerName: Equatable {
  case player1
  case player2
  case ai
  case custom(String)
}
extension PlayerName:CustomStringConvertible{
  var description: String{
    switch self{
    case .player1: "Player 1"
    case .player2: "Player 2"
    case .ai: "AI"
    case .custom(let name): name
    }
  }
}

