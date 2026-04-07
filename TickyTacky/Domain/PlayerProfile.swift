//
//  PlayerProfile.swift
//  TickyTacky
//
//  Created by M1 Pro on 7/4/26.
//

import SwiftUI


struct PlayerProfile: Equatable {
  var name:PlayerName
  var image: ImageResource
  var type: PlayerType
}

extension PlayerProfile {
  static var defaultPlayer1: Self{
    .init(name: .player1, image: .playerBoy1, type: .human)
  }
  
  static var defaultPlayer2: Self{
    .init(name: .ai, image: .playerBot1, type: .bot)
  }
}

