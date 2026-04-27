//
//  Achievement.swift
//  TickyTacky
//
//  Created by Antigravity on 4/27/26.
//

import Foundation

struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    var isUnlocked: Bool = false
    var unlockedDate: Date?
}

extension Achievement {
    static let allAchievements: [Achievement] = [
        .init(id: "first_win", title: "First Victory", description: "Win your very first match!", icon: "trophy.fill"),
        .init(id: "bot_slayer", title: "Bot Slayer", description: "Defeat the Bot on Hard difficulty.", icon: "cpu.fill"),
        .init(id: "speedster", title: "Speedster", description: "Win a match in under 10 seconds.", icon: "bolt.fill"),
        .init(id: "strategist", title: "Strategist", description: "Win a match in exactly 5 moves.", icon: "brain.fill"),
        .init(id: "tie_master", title: "Tie Master", description: "Get 5 tie matches in total.", icon: "hand.raised.fill"),
        .init(id: "unstoppable", title: "Unstoppable", description: "Win 3 matches in a row.", icon: "flame.fill")
    ]
}
