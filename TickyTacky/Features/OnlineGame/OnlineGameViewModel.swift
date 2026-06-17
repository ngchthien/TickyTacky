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
    
    @Published var p1Emoji: String?
    @Published var p2Emoji: String?
    
    @Published var myRematchRequested: Bool = false
    @Published var opponentRematchRequested: Bool = false
    @Published var showToast: Bool = false
    
    @Injected(\.appModeStore) private var appModeStore
    @Injected(\.onlineGameService) private var onlineGameService
    @Injected(\.hapticService) var hapticService
    @Injected(\.gameStore) private var gameStore
    @Injected(\.historyService) private var historyService
    @Injected(\.botEngineService) private var botEngine
    @Injected(\.achievementService) private var achievementService
    @Injected(\.qrCodeService) private var qrCodeService
    @Injected(\.analyticsService) private var analyticsService
    @Injected(\.leaderboardService) private var leaderboardService
    @Injected(\.toastManager) private var toastManager
    
    @AppStorage("online_win_streak") private var winStreak: Int = 0
    
    let roomID: String
    private var isMatchSaved: Bool = false
    private var turnTimerTask: Task<Void, Never>?
    private var matchStartTime: Date?
    
    private var p1EmojiLastTime: TimeInterval = 0
    private var p2EmojiLastTime: TimeInterval = 0
    private var p1EmojiTask: Task<Void, Never>? = nil
    private var p2EmojiTask: Task<Void, Never>? = nil
    private var observeTask: Task<Void, Never>?
    
    init(roomID: String) {
        self.roomID = roomID
        observeRoom()
    }
    
    deinit {
        observeTask?.cancel()
        turnTimerTask?.cancel()
        p1EmojiTask?.cancel()
        p2EmojiTask?.cancel()
    }
    
    func toggleReady() {
        let newState = !isReady
        isReady = newState
        onlineGameService.toggleReady(roomID: roomID, playerID: playerID, isReady: newState)
        hapticService.triggerImpact(style: .light)
    }
    
    func observeRoom() {
        observeTask?.cancel()
        observeTask = Task {
            for await room in onlineGameService.observeRoomStream(roomID: roomID) {
                self.updateRoom(room)
            }
        }
    }
    
    private func updateRoom(_ room: GameRoom) {
        let oldBoard = self.room?.board
        let oldStatus = self.room?.status
        self.room = room
        
        self.isReady = (playerID == room.player1ID) ? room.player1Ready : room.player2Ready
        if room.status == "playing" {
            self.isReady = true
        }
        
        self.board = room.board.map { CellState(symbol: $0) }.chunked(into: 3)
        
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
        
        if playerID == room.player1ID {
            myRematchRequested = room.player1Rematch
            opponentRematchRequested = room.player2Rematch
        } else {
            myRematchRequested = room.player2Rematch
            opponentRematchRequested = room.player1Rematch
        }
        
        // Process Player 1 Emoji
        if let emoji = room.player1Emoji, let timestamp = room.player1EmojiTimestamp, timestamp > p1EmojiLastTime {
            p1EmojiLastTime = timestamp
            showEmoji(emoji, for: room.player1ID)
        }
        
        // Process Player 2 Emoji
        if let emoji = room.player2Emoji, let timestamp = room.player2EmojiTimestamp, timestamp > p2EmojiLastTime {
            p2EmojiLastTime = timestamp
            if let p2ID = room.player2ID {
                showEmoji(emoji, for: p2ID)
            }
        }
        
        if oldStatus != "playing" && room.status == "playing" && matchStartTime == nil {
            matchStartTime = Date()
            analyticsService.trackGameStart(difficulty: "Online", firstTurn: room.currentTurn == playerID ? "you" : "opponent")
        }
        
        if room.status == "abandoned" {
            gameResultText = "Opponent left the room"
            return
        }
        
        if oldBoard != room.board {
            hapticService.triggerImpact(style: .light)
        }
        
        // When room becomes finished, handle the final match result once
        if room.status == "finished" && !isMatchSaved {
            Task {
                await handleFinalMatchEnd(winnerID: room.winnerID ?? "tie")
            }
        }
        
        checkWin()
        
        if room.status == "playing" && gameResultText == nil {
            startTurnTimer()
        } else {
            stopTurnTimer()
        }
    }
    
    private func checkWin() {
        guard let room = room, room.status == "playing" else { return }
        
        // This check is for the current round
        var roundWinner: String? = nil
        
        if let winningPath = gameStore.checkWin(in: board, for: .x) {
            winningCells = winningPath
            roundWinner = room.player1ID
        } else if let winningPath = gameStore.checkWin(in: board, for: .o) {
            winningCells = winningPath
            roundWinner = room.player2ID ?? ""
        } else if gameStore.isBoardFull(board) {
            roundWinner = "tie"
        }
        
        if let winner = roundWinner {
            stopTurnTimer()
            // Only report win if I am player 1 (host) to avoid double reporting
            // or if I'm the one who made the move that ended the round
            if playerID == room.player1ID {
                // Short delay to let player see the winning move
                Task {
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    self.onlineGameService.reportRoundWin(roomID: self.roomID, winnerID: winner)
                }
            }
        }
    }
    
    private func handleFinalMatchEnd(winnerID: String) async {
        isMatchSaved = true
        
        if winnerID == playerID {
            showConfetti = true
            gameResultText = AppStrings.youWon
            hapticService.triggerNotification(type: .success)
            winStreak += 1
            
            let myName = UserDefaults.standard.string(forKey: UserDefaultKeys.playerName) ?? "Player"
            leaderboardService.updateScore(userID: playerID, name: myName, pointsChange: 3)
        } else if winnerID == "tie" {
            gameResultText = AppStrings.itATie
            hapticService.triggerNotification(type: .warning)
            
            let myName = UserDefaults.standard.string(forKey: UserDefaultKeys.playerName) ?? "Player"
            leaderboardService.updateScore(userID: playerID, name: myName, pointsChange: 1)
        } else {
            gameResultText = AppStrings.youLost
            hapticService.triggerNotification(type: .error)
            winStreak = 0
            
            let myName = UserDefaults.standard.string(forKey: UserDefaultKeys.playerName) ?? "Player"
            leaderboardService.updateScore(userID: playerID, name: myName, pointsChange: -1)
        }
        
        analyticsService.trackGameEnd(result: winnerID == playerID ? "humanWin" : (winnerID == "tie" ? "tie" : "opponentWin"))
        
        let duration = matchStartTime.map { Date().timeIntervalSince($0) } ?? 0
        await saveToHistory(winnerID: winnerID, duration: duration)
        await checkOnlineAchievements(winnerID: winnerID, duration: duration)
        matchStartTime = nil
    }
    
    private func saveToHistory(winnerID: String, duration: TimeInterval) async {
        guard let room = room else { return }
        
        let resultType: String = (winnerID == playerID) ? "Win" : (winnerID == "tie" ? "Tie" : "Loss")
        let myName = UserDefaults.standard.string(forKey: UserDefaultKeys.playerName) ?? "You"
        let opponentName = (playerID == room.player1ID) ? (room.player2Name ?? "Opponent") : room.player1Name
        let winnerName: String? = (resultType == "Win") ? myName : (resultType == "Loss" ? opponentName : nil)
        
        let history = MatchHistory(
            player1Name: myName, player2Name: opponentName, winnerName: winnerName,
            date: Date(), duration: duration, difficulty: "Online", resultType: resultType
        )
        await historyService.saveMatch(history)
    }
    
    private func checkOnlineAchievements(winnerID: String, duration: TimeInterval) async {
        let result: GameResult = winnerID == playerID ? .humanWin : (winnerID == "tie" ? .tie : .botWin)
        let matches = await historyService.fetchAllMatches()
        let totalTies = matches.filter { $0.resultType == "Tie" && $0.difficulty == "Online" }.count
        let moveCount = room?.board.filter { !$0.isEmpty }.count ?? 0
        
        let unlocked = achievementService.checkAchievements(
            result: result, difficulty: .hard, duration: duration, 
            moveCount: moveCount, winStreak: winStreak, totalTies: totalTies
        )
        
        if !unlocked.isEmpty {
            withAnimation(.spring()) { newAchievements = unlocked }
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
        guard isMyTurn else {
            stopTurnTimer()
            return
        }
        if turnTimerTask != nil { return }
        turnCountdown = autoMoveTotalSeconds
        
        turnTimerTask = Task {
            while turnCountdown > 0 && !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if Task.isCancelled { break }
                
                turnCountdown -= 1
                if turnCountdown == 0 {
                    await autoMove()
                }
            }
        }
    }
    
    private func stopTurnTimer() {
        turnTimerTask?.cancel()
        turnTimerTask = nil
        turnCountdown = autoMoveTotalSeconds
    }
    
    private func autoMove() async {
        guard isMyTurn, let room = room, room.status == "playing" else { return }
        let move = await botEngine.bestMove(in: board, difficulty: .medium, botSymbol: mySymbol)
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
    
    private func showEmoji(_ emoji: String, for playerID: String) {
        let isP1 = playerID == room?.player1ID
        
        if isP1 {
            p1EmojiTask?.cancel()
            p1Emoji = emoji
            hapticService.triggerImpact(style: .light)
            p1EmojiTask = Task {
                try? await Task.sleep(nanoseconds: 2_500_000_000)
                if !Task.isCancelled { withAnimation { p1Emoji = nil } }
            }
        } else {
            p2EmojiTask?.cancel()
            p2Emoji = emoji
            hapticService.triggerImpact(style: .light)
            p2EmojiTask = Task {
                try? await Task.sleep(nanoseconds: 2_500_000_000)
                if !Task.isCancelled { withAnimation { p2Emoji = nil } }
            }
        }
    }
    
    func restartGame() {
        onlineGameService.restartRoom(roomID: roomID)
        hapticService.triggerImpact(style: .medium)
    }
    
    func quitGame() {
        onlineGameService.leaveRoom(roomID: roomID, playerID: playerID)
        appModeStore.goBack()
    }
    
    func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
        hapticService.triggerNotification(type: .success)
        toastManager.show(message: AppStrings.copied, type: .success)
    }
    
    var isMyTurn: Bool { room?.currentTurn == playerID }
    var mySymbol: CellState { room?.player1ID == playerID ? .x : .o }
    var qrCodeImage: UIImage? { qrCodeService.generateQRCode(from: roomID) }
    var displayWinningCells: [CellCoordinate] {
        gameResultText == AppStrings.youWon ? winningCells : []
    }
}
