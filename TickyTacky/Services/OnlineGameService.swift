//
//  OnlineGameService.swift
//  TickyTacky
//
//  Created by Antigravity on 4/27/26.
//

import Foundation
import FirebaseDatabase

enum OnlineGameError: LocalizedError {
    case roomNotFound
    case roomFull
    case internalError(String)
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .roomNotFound: return "Không tìm thấy phòng chơi."
        case .roomFull: return "Phòng đã đầy."
        case .internalError(let msg): return "Lỗi hệ thống: \(msg)"
        case .unauthorized: return "Bạn không có quyền thực hiện hành động này."
        }
    }
}

protocol OnlineGameServiceProtocol {
    func createRoom(playerName: String, isPublic: Bool) async throws -> (roomID: String, playerID: String)
    func joinRoom(roomID: String, playerName: String) async throws -> String
    func observePublicRooms(onUpdate: @escaping ([GameRoom]) -> Void)
    func observePublicRoomsStream() -> AsyncStream<[GameRoom]>
    func toggleReady(roomID: String, playerID: String, isReady: Bool)
    func sendMove(roomID: String, boardIndex: Int, playerID: String)
    func observeRoom(roomID: String, onUpdate: @escaping (GameRoom) -> Void)
    func observeRoomStream(roomID: String) -> AsyncStream<GameRoom>
    func leaveRoom(roomID: String, playerID: String)
    func restartRoom(roomID: String)
    func setWinner(roomID: String, winnerID: String)
    func reportRoundWin(roomID: String, winnerID: String)
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
    
    var player1Emoji: String?
    var player1EmojiTimestamp: TimeInterval?
    var player2Emoji: String?
    var player2EmojiTimestamp: TimeInterval?
    
    // Best of 3 scores
    var player1Score: Int
    var player2Score: Int
    
    init?(id: String, dict: [String: Any]) {
        guard let p1Name = dict["player1Name"] as? String,
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
        
        self.player1Emoji = dict["player1Emoji"] as? String
        self.player1EmojiTimestamp = dict["player1EmojiTimestamp"] as? TimeInterval
        self.player2Emoji = dict["player2Emoji"] as? String
        self.player2EmojiTimestamp = dict["player2EmojiTimestamp"] as? TimeInterval
        
        self.player1Score = dict["player1Score"] as? Int ?? 0
        self.player2Score = dict["player2Score"] as? Int ?? 0
    }
    
    static func from(id: String, dict: [String: Any]) -> GameRoom? {
        return GameRoom(id: id, dict: dict)
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
            "status": status,
            "player1Score": player1Score,
            "player2Score": player2Score
        ]
        if let p2Name = player2Name { dict["player2Name"] = p2Name }
        if let p2ID = player2ID { dict["player2ID"] = p2ID }
        if let winner = winnerID { dict["winnerID"] = winner }
        return dict
    }
}

import Factory

final class OnlineGameService: OnlineGameServiceProtocol {
    private let db = Database.database(url: "https://ticky-tacky-ios-default-rtdb.firebaseio.com/").reference()
    private var roomHandle: DatabaseHandle?
    @Injected(\.toastManager) private var toastManager
    
    init() {
        setupConnectivityObserver()
    }
    
    private func setupConnectivityObserver() {
        let connectedRef = db.child(".info/connected")
        connectedRef.observe(.value) { snapshot, _ in
            let connected = snapshot.value as? Bool ?? false
            if connected {
                print("Firebase: Connected to server")
            } else {
                print("Firebase: Disconnected from server")
                DispatchQueue.main.async {
                    self.toastManager.show(message: "Mất kết nối mạng. Đang thử lại...", type: .warning)
                }
            }
        }
    }
    
    func createRoom(playerName: String, isPublic: Bool) async throws -> (roomID: String, playerID: String) {
        let roomID = String(format: "%04d", Int.random(in: 1000...9999))
        let playerID = UUID().uuidString
        
        let roomDict: [String: Any] = [
            "id": roomID,
            "player1Name": playerName,
            "player1ID": playerID,
            "player1Ready": false,
            "player2Ready": false,
            "board": Array(repeating: "", count: 9),
            "currentTurn": playerID,
            "status": "waiting",
            "isPublic": isPublic,
            "player1Score": 0,
            "player2Score": 0
        ]
        
        let roomRef = db.child("rooms").child(roomID)
        try await roomRef.setValue(roomDict)
        
        try await roomRef.onDisconnectUpdateChildValues([
            "player1ID": NSNull(),
            "player1Name": NSNull(),
            "status": "abandoned"
        ])
        
        return (roomID, playerID)
    }
    
    func joinRoom(roomID: String, playerName: String) async throws -> String {
        let roomRef = db.child("rooms").child(roomID)
        let snapshot = try await roomRef.getData()
        
        guard snapshot.exists() else {
            throw OnlineGameError.roomNotFound
        }
        
        let playerID = UUID().uuidString
        
        let result: Result<Void, Error> = await withCheckedContinuation { continuation in
            roomRef.runTransactionBlock({ currentData in
                guard var room = currentData.value as? [String: Any] else {
                    return .success(withValue: currentData)
                }
                
                if room["player1ID"] == nil || room["player1ID"] as? NSNull != nil {
                    room["player1Name"] = playerName
                    room["player1ID"] = playerID
                    room["player1Ready"] = false
                } else if room["player2ID"] == nil || room["player2ID"] as? NSNull != nil {
                    room["player2Name"] = playerName
                    room["player2ID"] = playerID
                    room["player2Ready"] = false
                } else {
                    return .abort()
                }
                
                room["status"] = "waiting"
                currentData.value = room
                return .success(withValue: currentData)
            }) { (error, committed, snapshot) in
                if let error = error {
                    continuation.resume(returning: .failure(error))
                } else if !committed {
                    continuation.resume(returning: .failure(OnlineGameError.roomFull))
                } else {
                    continuation.resume(returning: .success(()))
                }
            }
        }
        
        switch result {
        case .success:
            let snapshot = try await roomRef.getData()
            if let dict = snapshot.value as? [String: Any] {
                if dict["player1ID"] as? String == playerID {
                    try await roomRef.onDisconnectUpdateChildValues(["player1ID": NSNull(), "player1Name": NSNull(), "status": "abandoned"])
                } else {
                    try await roomRef.onDisconnectUpdateChildValues(["player2ID": NSNull(), "player2Name": NSNull(), "status": "abandoned"])
                }
            }
            return playerID
        case .failure(let error):
            throw error
        }
    }
    
    func observePublicRooms(onUpdate: @escaping ([GameRoom]) -> Void) {
        db.child("rooms").observe(.value, with: { snapshot in
            guard let roomsDict = snapshot.value as? [String: [String: Any]] else {
                onUpdate([])
                return
            }
            
            let publicRooms = roomsDict.compactMap { (id, dict) -> GameRoom? in
                let isPublic = dict["isPublic"] as? Bool ?? false
                let status = dict["status"] as? String ?? ""
                let p2ID = dict["player2ID"] as? String
                
                if isPublic && status == "waiting" && p2ID == nil {
                    return GameRoom.from(id: id, dict: dict)
                }
                return nil
            }
            
            onUpdate(publicRooms)
        })
    }
    
    func observePublicRoomsStream() -> AsyncStream<[GameRoom]> {
        AsyncStream { continuation in
            let handle = db.child("rooms").observe(.value) { snapshot in
                guard let roomsDict = snapshot.value as? [String: [String: Any]] else {
                    continuation.yield([])
                    return
                }
                
                let publicRooms = roomsDict.compactMap { (id, dict) -> GameRoom? in
                    let isPublic = dict["isPublic"] as? Bool ?? false
                    let status = dict["status"] as? String ?? ""
                    let p2ID = dict["player2ID"] as? String
                    
                    if isPublic && status == "waiting" && p2ID == nil {
                        return GameRoom.from(id: id, dict: dict)
                    }
                    return nil
                }
                continuation.yield(publicRooms)
            }
            
            continuation.onTermination = { [weak self] _ in
                self?.db.child("rooms").removeObserver(withHandle: handle)
            }
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
            
            func isPlayerReady(_ key: String) -> Bool {
                if let val = room[key] as? Bool { return val }
                if let val = room[key] as? Int { return val == 1 }
                if let val = room[key] as? String { return val.lowercased() == "true" }
                return false
            }
            
            let p1Ready = isPlayerReady("player1Ready")
            let p2Ready = isPlayerReady("player2Ready")
            let p2ID = room["player2ID"] as? String
            let hasP2 = p2ID != nil && !(p2ID?.isEmpty ?? true)
            
            if p1Ready && p2Ready && hasP2 {
                room["status"] = "playing"
                room["board"] = Array(repeating: "", count: 9) 
                room["player1Score"] = 0
                room["player2Score"] = 0
                let candidates = [room["player1ID"] as? String, p2ID].compactMap { $0 }
                room["currentTurn"] = candidates.randomElement() ?? (room["player1ID"] as? String ?? "")
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
        roomHandle = roomRef.observe(.value) { snapshot, _ in
            if let dict = snapshot.value as? [String: Any], let room = GameRoom(id: snapshot.key, dict: dict) {
                onUpdate(room)
            }
        }
    }
    
    func observeRoomStream(roomID: String) -> AsyncStream<GameRoom> {
        AsyncStream { continuation in
            let roomRef = db.child("rooms").child(roomID)
            let handle = roomRef.observe(.value) { snapshot, _ in
                if let dict = snapshot.value as? [String: Any], let room = GameRoom(id: snapshot.key, dict: dict) {
                    continuation.yield(room)
                }
            }
            
            continuation.onTermination = { _ in
                roomRef.removeObserver(withHandle: handle)
            }
        }
    }
    
    func leaveRoom(roomID: String, playerID: String) {
        let roomRef = db.child("rooms").child(roomID)
        
        roomRef.runTransactionBlock { currentData in
            guard var room = currentData.value as? [String: Any] else { return .success(withValue: currentData) }
            
            if playerID == room["player1ID"] as? String {
                room["player1Name"] = nil
                room["player1ID"] = nil
                room["player1Ready"] = false
            } else if playerID == room["player2ID"] as? String {
                room["player2Name"] = nil
                room["player2ID"] = nil
                room["player2Ready"] = false
            }
            
            if room["player1ID"] != nil || room["player2ID"] != nil {
                room["status"] = "waiting"
                room["board"] = Array(repeating: "", count: 9) 
                room["winnerID"] = nil
                room["player1Score"] = 0
                room["player2Score"] = 0
                room["currentTurn"] = room["player1ID"] as? String ?? room["player2ID"] as? String ?? ""
            }
            
            if room["player1ID"] == nil && room["player2ID"] == nil {
                currentData.value = nil 
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
            room["player1Score"] = 0
            room["player2Score"] = 0
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
            
            let p1Rematch = room["player1Rematch"] as? Bool ?? false
            let p2Rematch = room["player2Rematch"] as? Bool ?? false
            
            if p1Rematch && p2Rematch {
                let p2ID = room["player2ID"] as? String
                let winnerID = room["winnerID"] as? String
                
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
                room["player1Score"] = 0
                room["player2Score"] = 0
                room["currentTurn"] = loserID ?? p1ID
            }
            
            currentData.value = room
            return .success(withValue: currentData)
        }
    }
    
    func sendEmoji(roomID: String, playerID: String, emoji: String) {
        let roomRef = db.child("rooms").child(roomID)
        roomRef.runTransactionBlock { currentData in
            guard var room = currentData.value as? [String: Any] else { return .success(withValue: currentData) }
            
            let timestamp = ServerValue.timestamp()
            if playerID == room["player1ID"] as? String {
                room["player1Emoji"] = emoji
                room["player1EmojiTimestamp"] = timestamp
            } else {
                room["player2Emoji"] = emoji
                room["player2EmojiTimestamp"] = timestamp
            }
            
            currentData.value = room
            return .success(withValue: currentData)
        }
    }
    
    func setWinner(roomID: String, winnerID: String) {
        let roomRef = db.child("rooms").child(roomID)
        Task {
            try? await roomRef.child("status").setValue("finished")
            try? await roomRef.child("winnerID").setValue(winnerID)
        }
    }
    
    func reportRoundWin(roomID: String, winnerID: String) {
        let roomRef = db.child("rooms").child(roomID)
        roomRef.runTransactionBlock { currentData in
            guard var room = currentData.value as? [String: Any] else { return .success(withValue: currentData) }
            
            let p1ID = room["player1ID"] as? String ?? ""
            let p2ID = room["player2ID"] as? String ?? ""
            
            var p1Score = room["player1Score"] as? Int ?? 0
            var p2Score = room["player2Score"] as? Int ?? 0
            
            if winnerID == p1ID {
                p1Score += 1
            } else if winnerID == p2ID {
                p2Score += 1
            }
            
            room["player1Score"] = p1Score
            room["player2Score"] = p2Score
            
            if p1Score >= 2 {
                room["status"] = "finished"
                room["winnerID"] = p1ID
            } else if p2Score >= 2 {
                room["status"] = "finished"
                room["winnerID"] = p2ID
            } else if winnerID == "tie" {
                room["board"] = Array(repeating: "", count: 9)
                room["currentTurn"] = [p1ID, p2ID].randomElement() ?? p1ID
            } else {
                room["board"] = Array(repeating: "", count: 9)
                room["currentTurn"] = winnerID // Winner goes first
            }
            
            currentData.value = room
            return .success(withValue: currentData)
        }
    }
}
