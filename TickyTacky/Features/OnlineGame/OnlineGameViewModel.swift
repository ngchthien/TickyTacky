//
//  OnlineGameViewModel.swift
//  TickyTacky
//
//  Created by Antigravity on 4/27/26.
//

import SwiftUI
import Factory
import Combine

private let autoMoveTotalSeconds = 10

@MainActor
final class OnlineGameViewModel: ObservableObject {
    @Published var room: GameRoom?
    @Published var board: [[CellState]] = Array(repeating: Array(repeating: .empty, count: 3), count: 3)
    @Published var playerID: String = UserDefaults.standard.string(forKey: "online_player_id") ?? ""
    @Published var winningCells: [CellCoordinate] = []
    @Published var gameResultText: String?
    @Published var isReady: Bool = false
    @Published var showConfetti: Bool = false
    @Published var turnCountdown: Int = autoMoveTotalSeconds
    @Published var newAchievements: [Achievement] = []
    @Published var showQRCode: Bool = false
    @Published var activeEmoji: String?
    @Published var emojiSenderID: String?
    @Published var myRematchRequested: Bool = false
    @Published var opponentRematchRequested: Bool = false
    
    @Injected(\.appModeStore) private var appModeStore
    @Injected(\.onlineGameService) private var onlineGameService
    @Injected(\.hapticService) var hapticService
    @Injected(\.gameStore) private var gameStore
    @Injected(\.historyService) private var historyService
    @Injected(\.botEngineService) private var botEngine
    @Injected(\.achievementService) private var achievementService
    @Injected(\.qrCodeService) private var qrCodeService
    @Injected(\.analyticsService) private var analyticsService
    
    @AppStorage("online_win_streak") private var winStreak: Int = 0
    
    let roomID: String
    private var isMatchSaved: Bool = false
    private var turnTimer: Timer?
    private var matchStartTime: Date?
    
    init(roomID: String) {
        self.roomID = roomID
        observeRoom()
    }
    
    func toggleReady() {
        let newState = !isReady
        isReady = newState
        onlineGameService.toggleReady(roomID: roomID, playerID: playerID, isReady: newState)
        hapticService.triggerImpact(style: .light)
    }
    
    func observeRoom() {
        onlineGameService.observeRoom(roomID: roomID) { [weak self] room in
            Task { @MainActor in
                self?.updateRoom(room)
            }
        }
    }
    
    private func updateRoom(_ room: GameRoom) {
        let oldBoard = self.room?.board
        let oldStatus = self.room?.status
        self.room = room
        
        // Sync local isReady state with server
        self.isReady = (playerID == room.player1ID) ? room.player1Ready : room.player2Ready
        if room.status == "playing" {
            self.isReady = true
        }
        
        self.board = room.board.map { CellState(symbol: $0) }.chunked(into: 3)
        
        // Handle transitions
        if (oldStatus == "finished" && room.status == "playing") || room.status == "waiting" {
            winningCells = []
            showConfetti = false
            gameResultText = nil
            newAchievements = []
            if room.status == "playing" || room.status == "waiting" {
                isMatchSaved = false
            }
            myRematchRequested = false
            opponentRematchRequested = false
        }
        
        // Sync rematch states
        if playerID == room.player1ID {
            myRematchRequested = room.player1Rematch
            opponentRematchRequested = room.player2Rematch
        } else {
            myRematchRequested = room.player2Rematch
            opponentRematchRequested = room.player1Rematch
        }
        
        // Handle Emoji
        if let emoji = room.lastEmoji, 
           let sender = room.lastEmojiSender, 
           let timestamp = room.lastEmojiTimestamp,
           timestamp > (Date().timeIntervalSince1970 - 2000) { // Firebase timestamp is ms, but we'll check it
            // Simple check: if it's new (last 3 seconds)
            let now = Date().timeIntervalSince1970 * 1000
            if now - timestamp < 3000 {
                showEmoji(emoji, from: sender)
            }
        }
        
        // Start tracking time when game begins
        if oldStatus != "playing" && room.status == "playing" && matchStartTime == nil {
            matchStartTime = Date()
            analyticsService.trackGameStart(difficulty: "Online", firstTurn: room.currentTurn == playerID ? "you" : "opponent")
        }
        if room.status == "waiting" {
            matchStartTime = nil
        }
        
        if room.status == "abandoned" {
            gameResultText = "Opponent left the room"
            return
        }
        
        // Update board array
        for i in 0..<9 {
            let row = i / 3
            let col = i % 3
            let symbol = room.board[i]
            board[row][col] = (symbol == "X") ? .x : (symbol == "O" ? .o : .empty)
        }
        
        // Trigger haptic if board changed
        if oldBoard != room.board {
            hapticService.triggerImpact(style: .light)
        }
        
        // Check for win locally to show effects immediately for both
        checkWin()
        
        // Manage turn timer
        if room.status == "playing" && gameResultText == nil {
            startTurnTimer()
        } else {
            stopTurnTimer()
        }
    }
    
    private func checkWin() {
        guard let room = room else { return }
        
        // Map board to CellState for the existing checkWin logic
        if let winningPath = gameStore.checkWin(in: board, for: .x) {
            winningCells = winningPath
            stopTurnTimer()
            handleGameEnd(winnerID: room.player1ID)
        } else if let winningPath = gameStore.checkWin(in: board, for: .o) {
            winningCells = winningPath
            stopTurnTimer()
            handleGameEnd(winnerID: room.player2ID ?? "")
        } else if gameStore.isBoardFull(board) {
            stopTurnTimer()
            handleGameEnd(winnerID: "tie")
        }
    }
    
    private func handleGameEnd(winnerID: String) {
        guard !isMatchSaved else { return }
        
        if room?.status == "playing" {
            // Only one player needs to update the DB status
            // Host (player1) will take responsibility
            if playerID == room?.player1ID {
                onlineGameService.setWinner(roomID: roomID, winnerID: winnerID)
            }
        }
        
        // Show effects
        if winnerID == playerID {
            showConfetti = true
            gameResultText = "You Won!"
            hapticService.triggerNotification(type: .success)
            winStreak += 1
        } else if winnerID == "tie" {
            gameResultText = "It's a Tie!"
            hapticService.triggerNotification(type: .warning)
        } else {
            gameResultText = "You Lost!"
            hapticService.triggerNotification(type: .error)
            winStreak = 0
        }
        
        analyticsService.trackGameEnd(result: winnerID == playerID ? "humanWin" : (winnerID == "tie" ? "tie" : "opponentWin"))
        
        let duration = matchStartTime.map { Date().timeIntervalSince($0) } ?? 0
        saveToHistory(winnerID: winnerID, duration: duration)
        checkOnlineAchievements(winnerID: winnerID, duration: duration)
        matchStartTime = nil
        isMatchSaved = true
    }
    
    private func saveToHistory(winnerID: String, duration: TimeInterval) {
        guard let room = room else { return }
        
        let resultType: String
        if winnerID == playerID {
            resultType = "Win"
        } else if winnerID == "tie" {
            resultType = "Tie"
        } else {
            resultType = "Loss"
        }
        
        let myName = UserDefaults.standard.string(forKey: UserDefaultKeys.playerName) ?? "You"
        let opponentName = (playerID == room.player1ID) ? (room.player2Name ?? "Opponent") : room.player1Name
        
        let winnerName: String?
        if resultType == "Win" {
            winnerName = myName
        } else if resultType == "Loss" {
            winnerName = opponentName
        } else {
            winnerName = nil
        }
        
        let history = MatchHistory(
            player1Name: myName,
            player2Name: opponentName,
            winnerName: winnerName,
            date: Date(),
            duration: duration,
            difficulty: "Online",
            resultType: resultType
        )
        
        historyService.saveMatch(history)
    }
    
    private func checkOnlineAchievements(winnerID: String, duration: TimeInterval) {
        let result: GameResult = winnerID == playerID ? .humanWin : (winnerID == "tie" ? .tie : .botWin)
        let totalTies = historyService.fetchAllMatches().filter { $0.resultType == "Tie" && $0.difficulty == "Online" }.count
        let moveCount = room?.board.filter { !$0.isEmpty }.count ?? 0
        
        let unlocked = achievementService.checkAchievements(
            result: result,
            difficulty: .hard, // online is always "hard" (real human)
            duration: duration,
            moveCount: moveCount,
            winStreak: winStreak,
            totalTies: totalTies
        )
        
        if !unlocked.isEmpty {
            withAnimation(.spring()) {
                newAchievements = unlocked
            }
        }
    }
    
    func playMove(index: Int) {
        guard let room = room, room.status == "playing" else { return }
        guard room.currentTurn == playerID else { return }
        guard room.board[index] == "" else { return }
        
        onlineGameService.sendMove(roomID: roomID, boardIndex: index, playerID: playerID)
        stopTurnTimer()
    }
    
    // MARK: - Turn Timer
    
    private func startTurnTimer() {
        // Only run timer for the current player's turn
        guard isMyTurn else {
            stopTurnTimer()
            return
        }
        
        // Don't restart if a timer is already running for this turn
        if turnTimer != nil { return }
        
        turnCountdown = autoMoveTotalSeconds
        turnTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if self.turnCountdown > 1 {
                    self.turnCountdown -= 1
                } else {
                    self.stopTurnTimer()
                    self.autoMove()
                }
            }
        }
    }
    
    private func stopTurnTimer() {
        turnTimer?.invalidate()
        turnTimer = nil
        turnCountdown = autoMoveTotalSeconds
    }
    
    private func autoMove() {
        guard isMyTurn, let room = room, room.status == "playing" else { return }
        let move = botEngine.bestMove(in: board, difficulty: .medium, botSymbol: mySymbol)
        let index = move.row * 3 + move.col
        onlineGameService.sendMove(roomID: roomID, boardIndex: index, playerID: playerID)
        hapticService.triggerImpact(style: .medium)
    }
    
    func requestRematch() {
        onlineGameService.requestRematch(roomID: roomID, playerID: playerID)
        hapticService.triggerImpact(style: .medium)
    }
    
    func sendEmoji(_ emoji: String) {
        onlineGameService.sendEmoji(roomID: roomID, playerID: playerID, emoji: emoji)
        hapticService.triggerImpact(style: .light)
    }
    
    private func showEmoji(_ emoji: String, from senderID: String) {
        activeEmoji = emoji
        emojiSenderID = senderID
        
        // Hide after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            if self.activeEmoji == emoji {
                self.activeEmoji = nil
                self.emojiSenderID = nil
            }
        }
    }
    
    func restartGame() {
        onlineGameService.restartRoom(roomID: roomID)
        hapticService.triggerImpact(style: .medium)
    }
    
    func quitGame() {
        onlineGameService.leaveRoom(roomID: roomID, playerID: playerID)
        appModeStore.goHome()
    }
    
    var isMyTurn: Bool {
        room?.currentTurn == playerID
    }
    
    var mySymbol: CellState {
        room?.player1ID == playerID ? .x : .o
    }
    
    var qrCodeImage: UIImage? {
        qrCodeService.generateQRCode(from: roomID)
    }
    
    /// Only show winning line highlight to the winner, not the loser
    var displayWinningCells: [CellCoordinate] {
        gameResultText == "You Won!" ? winningCells : []
    }
}
