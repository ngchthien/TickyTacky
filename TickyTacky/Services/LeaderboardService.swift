//
//  LeaderboardService.swift
//  TickyTacky
//
//  Created by Antigravity on 4/29/26.
//

import Foundation
import FirebaseDatabase

struct LeaderboardEntry: Identifiable, Codable {
    var id: String
    var name: String
    var points: Int
    var lastUpdated: TimeInterval
}

protocol LeaderboardServiceProtocol {
    func updateScore(userID: String, name: String, pointsChange: Int)
    func fetchTopScores(limit: Int) async throws -> [LeaderboardEntry]
}

final class LeaderboardService: LeaderboardServiceProtocol {
    private let db = Database.database().reference()
    
    func updateScore(userID: String, name: String, pointsChange: Int) {
        let userRef = db.child("leaderboard").child(userID)
        
        userRef.runTransactionBlock { currentData in
            var dict = currentData.value as? [String: Any] ?? [
                "id": userID,
                "name": name,
                "points": 0,
                "lastUpdated": ServerValue.timestamp()
            ]
            
            let currentPoints = dict["points"] as? Int ?? 0
            // Ensure points don't go below 0
            dict["points"] = max(0, currentPoints + pointsChange)
            dict["name"] = name
            dict["lastUpdated"] = ServerValue.timestamp()
            
            currentData.value = dict
            return .success(withValue: currentData)
        }
    }
    
    func fetchTopScores(limit: Int = 10) async throws -> [LeaderboardEntry] {
        let snapshot = try await db.child("leaderboard")
            .queryOrdered(byChild: "points")
            .queryLimited(toLast: UInt(limit))
            .getData()
        
        guard let dict = snapshot.value as? [String: [String: Any]] else {
            return []
        }
        
        let entries = dict.compactMap { (key, value) -> LeaderboardEntry? in
            guard let name = value["name"] as? String,
                  let points = value["points"] as? Int else { return nil }
            
            return LeaderboardEntry(
                id: key,
                name: name,
                points: points,
                lastUpdated: value["lastUpdated"] as? TimeInterval ?? 0
            )
        }
        
        // Reverse for descending order
        return entries.sorted { $0.points > $1.points }
    }
}
