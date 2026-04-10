//
//  FirstTurn.swift
//  TickyTacky
//
//  Created by M1 Pro on 10/4/26.
//

import Foundation

enum FirstTurn:String,CaseIterable{
  case you
  case opponent
  case random
}

extension FirstTurn:CustomStringConvertible{
  var description: String{
    rawValue.capitalized
  }
}
