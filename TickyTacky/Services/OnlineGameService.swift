//
//  OnlineGameService.swift
//  TickyTacky
//
//  Created by Antigravity on 4/27/26.
//

import Foundation
import FirebaseDatabase

protocol OnlineGameServiceProtocol {
    func createRoom(playerName: String) async throws -> String
    func joinRoom(roomID: String, playerName: String) async throws
    func toggleReady(roomID: String, playerID: String, isReady: Bool)
    func sendMove(roomID: String, boardIndex: Int, playerID: String)
    func observeRoom(roomID: String, onUpdate: @escaping (GameRoom) -> Void)
    func leaveRoom(roomID: String, playerID: String)
    func restartRoom(roomID: String)
    func setWinner(roomID: String, winnerID: String)
    func requestRematch(roomID: String, playerID: String)
    func sendEmoji(roomID: String, playerID: String, emoji: String)
}

struct GameRoom {
    var id: String
    var player1Name: String
    var player1ID: String
    var player2Name: String?
    var player2ID: String?
    var player1Ready: Bool
    var player2Ready: Bool
    var board: [String]
    var currentTurn: String
    var status: String
    var winnerID: String?
    var player1Rematch: Bool
    var player2Rematch: Bool
    var lastEmoji: String?
    var lastEmojiSender: String?
    var lastEmojiTimestamp: TimeInterval?
    
    init?(dict: [String: Any]) {
        guard let id = dict["id"] as? String,
              let p1Name = dict["player1Name"] as? String,
              let p1ID = dict["player1ID"] as? String,
              let turn = dict["currentTurn"] as? String,
              let status = dict["status"] as? String,
              let board = dict["board"] as? [String] else { return nil }
        
        self.id = id
        self.player1Name = p1Name
        self.player1ID = p1ID
        self.player2Name = dict["player2Name"] as? String
        self.player2ID = dict["player2ID"] as? String
        self.player1Ready = dict["player1Ready"] as? Bool ?? false
        self.player2Ready = dict["player2Ready"] as? Bool ?? false
        self.board = board
        self.currentTurn = turn
        self.status = status
        self.winnerID = dict["winnerID"] as? String
        self.player1Rematch = dict["player1Rematch"] as? Bool ?? false
        self.player2Rematch = dict["player2Rematch"] as? Bool ?? false
        self.lastEmoji = dict["lastEmoji"] as? String
        self.lastEmojiSender = dict["lastEmojiSender"] as? String
        self.lastEmojiTimestamp = dict["lastEmojiTimestamp"] as? TimeInterval
    }
    
    func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "player1Name": player1Name,
            "player1ID": player1ID,
            "player1Ready": player1Ready,
            "player2Ready": player2Ready,
            "board": board,
            "currentTurn": currentTurn,
            "status": status
        ]
        if let p2Name = player2Name { dict["player2Name"] = p2Name }
        if let p2ID = player2ID { dict["player2ID"] = p2ID }
        if let winner = winnerID { dict["winnerID"] = winner }
        return dict
    }
}

final class OnlineGameService: OnlineGameServiceProtocol {
    private let db = Database.database(url: "https://ticky-tacky-ios-default-rtdb.firebaseio.com/").reference()
    private var roomHandle: DatabaseHandle?
    
    func createRoom(playerName: String) async throws -> String {
        let roomID = String(format: "%04d", Int.random(in: 1000...9999))
        let playerID = UUID().uuidString
        
        let roomDict: [String: Any] = [
            "id": roomID,
            "player1Name": playerName,
            "player1ID": playerID,
            "board": Array(repeating: "", count: 9),
            "currentTurn": playerID,
            "status": "waiting"
        ]
        
        let roomRef = db.child("rooms").child(roomID)
        try await roomRef.setValue(roomDict)
        
        // If the host disconnects before anyone joins, delete the room
        try? await roomRef.onDisconnectRemoveValue()
        
        UserDefaults.standard.set(playerID, forKey: "online_player_id")
        
        return roomID
    }
    
    func joinRoom(roomID: String, playerName: String) async throws {
        let playerID = UUID().uuidString
        let roomRef = db.child("rooms").child(roomID)
        
        let result = await withCheckedContinuation { continuation in
            roomRef.runTransactionBlock({ currentData in
                guard var dict = currentData.value as? [String: Any] else {
                    return .success(withValue: currentData)
                }
                
                // Find an empty slot
                if dict["player1ID"] == nil {
                    dict["player1Name"] = playerName
                    dict["player1ID"] = playerID
                    dict["player1Ready"] = false
                } else if dict["player2ID"] == nil {
                    dict["player2Name"] = playerName
                    dict["player2ID"] = playerID
                    dict["player2Ready"] = false
                } else if dict["player1ID"] as? String != playerID && dict["player2ID"] as? String != playerID {
                    // Only throw if it's actually full and we are not already in it
                    return .abort()
                }
                
                dict["status"] = "waiting"
                currentData.value = dict
                return .success(withValue: currentData)
            }) { (error, committed, snapshot) in
                if let error = error {
                    continuation.resume(returning: Result<Void, Error>.failure(error))
                } else if !committed {
                    continuation.resume(returning: Result<Void, Error>.failure(NSError(domain: "Game", code: 400, userInfo: [NSLocalizedDescriptionKey: "Room is full or not found"])))
                } else {
                    continuation.resume(returning: Result<Void, Error>.success(()))
                }
            }
        }
        
        switch result {
        case .success:
            UserDefaults.standard.set(playerID, forKey: "online_player_id")
        case .failure(let error):
            throw error
        }
    }
    
    func toggleReady(roomID: String, playerID: String, isReady: Bool) {
        let roomRef = db.child("rooms").child(roomID)
        roomRef.runTransactionBlock { currentData in
            guard var room = currentData.value as? [String: Any] else { return .success(withValue: currentData) }
            
            if playerID == room["player1ID"] as? String {
                room["player1Ready"] = isReady
            } else if playerID == room["player2ID"] as? String {
                room["player2Ready"] = isReady
            }
            
            // Auto start if both are ready
            func isPlayerReady(_ key: String) -> Bool {
                if let val = room[key] as? Bool { return val }
                if let val = room[key] as? Int { return val == 1 }
                return false
            }
            
            let p1Ready = isPlayerReady("player1Ready")
            let p2Ready = isPlayerReady("player2Ready")
            let p1ID = room["player1ID"] as? String
            let p2ID = room["player2ID"] as? String
            let hasP2 = p2ID != nil
            
            if p1Ready && p2Ready && hasP2 {
                room["status"] = "playing"
                room["board"] = Array(repeating: "", count: 9) // Clear board just in case
                // Randomize who goes first
                let candidates = [p1ID, p2ID].compactMap { $0 }
                room["currentTurn"] = candidates.randomElement() ?? (p1ID ?? "")
            }
            
            currentData.value = room
            return .success(withValue: currentData)
        }
    }
    
    func sendMove(roomID: String, boardIndex: Int, playerID: String) {
        let roomRef = db.child("rooms").child(roomID)
        
        roomRef.runTransactionBlock { currentData in
            guard var room = currentData.value as? [String: Any] else { return .success(withValue: currentData) }
            
            let turn = room["currentTurn"] as? String
            let status = room["status"] as? String
            var board = room["board"] as? [String] ?? Array(repeating: "", count: 9)
            
            if turn == playerID && status == "playing" && board[boardIndex] == "" {
                board[boardIndex] = (playerID == room["player1ID"] as? String) ? "X" : "O"
                room["board"] = board
                room["currentTurn"] = (playerID == room["player1ID"] as? String) ? room["player2ID"] : room["player1ID"]
                currentData.value = room
            }
            
            return .success(withValue: currentData)
        }
    }
    
    func observeRoom(roomID: String, onUpdate: @escaping (GameRoom) -> Void) {
        let roomRef = db.child("rooms").child(roomID)
        roomHandle = roomRef.observe(.value) { snapshot in
            if let dict = snapshot.value as? [String: Any], let room = GameRoom(dict: dict) {
                onUpdate(room)
            }
        }
    }
    
    func leaveRoom(roomID: String, playerID: String) {
        let roomRef = db.child("rooms").child(roomID)
        
        roomRef.runTransactionBlock { currentData in
            guard var room = currentData.value as? [String: Any] else { return .success(withValue: currentData) }
            
            let status = room["status"] as? String ?? ""
            
            // 1. Identify and clear the player who is leaving
            if playerID == room["player1ID"] as? String {
                room["player1Name"] = nil
                room["player1ID"] = nil
                room["player1Ready"] = false
            } else if playerID == room["player2ID"] as? String {
                room["player2Name"] = nil
                room["player2ID"] = nil
                room["player2Ready"] = false
            }
            
            // 2. Handle room status
            if room["player1ID"] != nil || room["player2ID"] != nil {
                // If someone is still here, reset to waiting so others can join
                room["status"] = "waiting"
                room["board"] = Array(repeating: "", count: 9) // Reset board too
                room["winnerID"] = nil
                room["currentTurn"] = room["player1ID"] as? String ?? room["player2ID"] as? String ?? ""
            }
            
            // 3. Final Check: If BOTH players are gone, delete the room permanently
            if room["player1ID"] == nil && room["player2ID"] == nil {
                currentData.value = nil // This deletes the node from Firebase
            } else {
                currentData.value = room
            }
            
            return .success(withValue: currentData)
        }
        
        if let handle = roomHandle {
            db.child("rooms").child(roomID).removeObserver(withHandle: handle)
            roomHandle = nil
        }
    }
    
    func restartRoom(roomID: String) {
        let roomRef = db.child("rooms").child(roomID)
        roomRef.runTransactionBlock { currentData in
            guard var room = currentData.value as? [String: Any] else { return .success(withValue: currentData) }
            
            let p1ID = room["player1ID"] as? String
            let p2ID = room["player2ID"] as? String
            let winnerID = room["winnerID"] as? String
            
            // Loser goes first next round. On tie, pick randomly.
            let loserID: String?
            if winnerID == nil || winnerID == "tie" {
                loserID = [p1ID, p2ID].compactMap { $0 }.randomElement()
            } else if winnerID == p1ID {
                loserID = p2ID
            } else {
                loserID = p1ID
            }
            
            room["board"] = Array(repeating: "", count: 9)
            room["status"] = "playing"
            room["winnerID"] = nil
            room["player1Rematch"] = false
            room["player2Rematch"] = false
            room["currentTurn"] = loserID ?? p1ID ?? ""
            
            currentData.value = room
            return .success(withValue: currentData)
        }
    }
    
    func requestRematch(roomID: String, playerID: String) {
        db.child("rooms").child(roomID).runTransactionBlock { currentData in
            guard var room = currentData.value as? [String: Any] else { return .success(withValue: currentData) }
            
            let p1ID = room["player1ID"] as? String ?? ""
            if playerID == p1ID {
                room["player1Rematch"] = true
            } else {
                room["player2Rematch"] = true
            }
            
            // If both want rematch, auto restart
            let p1Rematch = room["player1Rematch"] as? Bool ?? false
            let p2Rematch = room["player2Rematch"] as? Bool ?? false
            
            if p1Rematch && p2Rematch {
                let p2ID = room["player2ID"] as? String
                let winnerID = room["winnerID"] as? String
                
                // Loser goes first
                let loserID: String?
                if winnerID == nil || winnerID == "tie" {
                    loserID = [p1ID, p2ID].compactMap { $0 }.randomElement()
                } else if winnerID == p1ID {
                    loserID = p2ID
                } else {
                    loserID = p1ID
                }
                
                room["board"] = Array(repeating: "", count: 9)
                room["status"] = "playing"
                room["winnerID"] = nil
                room["player1Rematch"] = false
                room["player2Rematch"] = false
                room["currentTurn"] = loserID ?? p1ID
            }
            
            currentData.value = room
            return .success(withValue: currentData)
        }
    }
    
    func sendEmoji(roomID: String, playerID: String, emoji: String) {
        let update: [String: Any] = [
            "lastEmoji": emoji,
            "lastEmojiSender": playerID,
            "lastEmojiTimestamp": ServerValue.timestamp()
        ]
        db.child("rooms").child(roomID).updateChildValues(update)
    }
    
    func setWinner(roomID: String, winnerID: String) {
        let roomRef = db.child("rooms").child(roomID)
        Task {
            try? await roomRef.child("status").setValue("finished")
            try? await roomRef.child("winnerID").setValue(winnerID)
        }
    }
}
