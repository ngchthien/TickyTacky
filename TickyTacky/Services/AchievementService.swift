//
//  AchievementService.swift
//  TickyTacky
//
//  Created by Antigravity on 4/27/26.
//

import Foundation
import SwiftUI

protocol AchievementServiceProtocol {
    var unlockedIDs: Set<String> { get }
    func unlock(id: String)
    func isUnlocked(id: String) -> Bool
    func checkAchievements(
        result: GameResult,
        difficulty: Difficulty,
        duration: TimeInterval,
        moveCount: Int,
        winStreak: Int,
        totalTies: Int
    ) -> [Achievement]
}

final class AchievementService: AchievementServiceProtocol {
    @AppStorage("unlocked_achievements") private var unlockedIDsData: Data = Data()
    
    var unlockedIDs: Set<String> {
        get {
            (try? JSONDecoder().decode(Set<String>.self, from: unlockedIDsData)) ?? []
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                unlockedIDsData = data
            }
        }
    }
    
    func unlock(id: String) {
        var current = unlockedIDs
        if !current.contains(id) {
            current.insert(id)
            unlockedIDs = current
            // In a more complex app, we'd save the unlock date here in a dictionary
            // [String: Date], but since we only have a Set<String> for IDs right now,
            // we'll keep it simple.
        }
    }
    
    func isUnlocked(id: String) -> Bool {
        unlockedIDs.contains(id)
    }
    
    func checkAchievements(
        result: GameResult,
        difficulty: Difficulty,
        duration: TimeInterval,
        moveCount: Int,
        winStreak: Int,
        totalTies: Int
    ) -> [Achievement] {
        var newlyUnlocked: [Achievement] = []
        let all = Achievement.allAchievements
        
        // 1. First Win
        if result == .humanWin, !isUnlocked(id: "first_win") {
            unlock(id: "first_win")
            newlyUnlocked.append(all.first { $0.id == "first_win" }!)
        }
        
        // 2. Bot Slayer
        if result == .humanWin, difficulty == .hard, !isUnlocked(id: "bot_slayer") {
            unlock(id: "bot_slayer")
            newlyUnlocked.append(all.first { $0.id == "bot_slayer" }!)
        }
        
        // 3. Speedster
        if result == .humanWin, duration < 10, !isUnlocked(id: "speedster") {
            unlock(id: "speedster")
            newlyUnlocked.append(all.first { $0.id == "speedster" }!)
        }
        
        // 4. Strategist (X wins in 5 moves)
        if result == .humanWin, moveCount == 5, !isUnlocked(id: "strategist") {
            unlock(id: "strategist")
            newlyUnlocked.append(all.first { $0.id == "strategist" }!)
        }
        
        // 5. Tie Master
        if totalTies >= 5, !isUnlocked(id: "tie_master") {
            unlock(id: "tie_master")
            newlyUnlocked.append(all.first { $0.id == "tie_master" }!)
        }
        
        // 6. Unstoppable
        if winStreak >= 3, !isUnlocked(id: "unstoppable") {
            unlock(id: "unstoppable")
            newlyUnlocked.append(all.first { $0.id == "unstoppable" }!)
        }
        
        return newlyUnlocked
    }
}
