//
//  PlayerType.swift
//  TickyTacky
//
//  Created by M1 Pro on 7/4/26.
//

import Foundation

enum PlayerType: Equatable {
  case human
  case bot
}
extension PlayerType{
  var isHuman:Bool{
    self == .human
  }
  
  var isBot: Bool{
    self == .bot
  }
}
