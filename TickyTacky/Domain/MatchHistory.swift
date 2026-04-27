//
//  MatchHistory.swift
//  TickyTacky
//
//  Created by Antigravity on 4/27/26.
//

import Foundation
import SwiftData

@Model
final class MatchHistory {
    var id: UUID
    var player1Name: String
    var player2Name: String
    var winnerName: String? // nil nếu hòa
    var date: Date
    var duration: TimeInterval
    var difficulty: String
    var resultType: String // "Win", "Loss", "Tie" (từ góc nhìn Player 1)
    
    init(
        player1Name: String,
        player2Name: String,
        winnerName: String? = nil,
        date: Date = Date(),
        duration: TimeInterval,
        difficulty: String,
        resultType: String
    ) {
        self.id = UUID()
        self.player1Name = player1Name
        self.player2Name = player2Name
        self.winnerName = winnerName
        self.date = date
        self.duration = duration
        self.difficulty = difficulty
        self.resultType = resultType
    }
}
