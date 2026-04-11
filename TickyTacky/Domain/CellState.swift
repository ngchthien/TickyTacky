//
//  CellState.swift
//  TickyTacky
//
//  Created by Raul Gutierrez Niubo on 9/23/25.
//

import SwiftUI

enum CellState {
    case empty
    case x
    case o
    
    var symbol: String {
        switch self {
        case .x: return "X"
        case .o: return "O"
        case .empty: return ""
        }
    }
    
    var color: Color {
        switch self {
        case .x: return Color.appTheme.accent
        case .o: return Color.appTheme.alternateAccent
        case .empty: return Color.clear
        }
    }
}
