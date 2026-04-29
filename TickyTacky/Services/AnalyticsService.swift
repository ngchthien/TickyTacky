//
//  AnalyticsService.swift
//  TickyTacky
//
//  Created by M1 Pro on 11/4/26.
//

import Foundation
import FirebaseAnalytics

protocol AnalyticsProtocol {
    func trackGameStart(difficulty: String, firstTurn: String)
    func trackGameEnd(result: String)
    func trackError(_ error: String)
    func trackRoomAction(action: String, method: String)
    func trackAchievement(id: String)
}

final class AnalyticsService: AnalyticsProtocol {
    
    func trackGameStart(difficulty: String, firstTurn: String) {
        Analytics.logEvent("game_start", parameters: [
            "difficulty": difficulty,
            "first_turn": firstTurn
        ])
    }
    
    func trackGameEnd(result: String) {
        Analytics.logEvent("game_end", parameters: [
            "result": result
        ])
    }
    
    func trackRoomAction(action: String, method: String) {
        Analytics.logEvent("online_room_action", parameters: [
            "action": action, // "create" or "join"
            "method": method  // "manual" or "qr"
        ])
    }
    
    func trackAchievement(id: String) {
        Analytics.logEvent("achievement_unlocked", parameters: [
            "achievement_id": id
        ])
    }
    
    func trackError(_ error: String) {
        Analytics.logEvent("game_error", parameters: [
            "error_description": error
        ])
    }
}
