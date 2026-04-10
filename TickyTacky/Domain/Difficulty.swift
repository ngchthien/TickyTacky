//
//  Difficulty.swift
//  TickyTacky
//
//  Created by M1 Pro on 10/4/26.
//

import Foundation


enum Difficulty :String, CaseIterable{
  case easy
  case medium
  case hard
}
extension Difficulty: CustomStringConvertible{
  
  var description: String{
    rawValue.capitalized
  }
}
