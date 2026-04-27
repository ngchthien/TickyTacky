//
//  AchievementsViewModel.swift
//  TickyTacky
//
//  Created by Antigravity on 4/27/26.
//

import SwiftUI
import Factory
import Combine
@MainActor
final class AchievementsViewModel: ObservableObject {
    @Published var achievements: [Achievement] = []
    
    @Injected(\.achievementService) private var achievementService
    
    init() {
        loadAchievements()
    }
    
    func loadAchievements() {
        let all = Achievement.allAchievements
        achievements = all.map { achievement in
            var updated = achievement
            updated.isUnlocked = achievementService.isUnlocked(id: achievement.id)
            return updated
        }
    }
}
