//
//  OnlineLobbyViewModel.swift
//  TickyTacky
//
//  Created by Antigravity on 4/27/26.
//

import SwiftUI
import Factory
import Combine
@MainActor
final class OnlineLobbyViewModel: ObservableObject {
    @Published var playerName: String = ""
    @Published var roomCode: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showScanner: Bool = false
    
    @Injected(\.appModeStore) private var appModeStore
    @Injected(\.onlineGameService) private var onlineGameService
    @Injected(\.hapticService) var hapticService
    @Injected(\.analyticsService) private var analyticsService
    
    init() {
        self.playerName = UserDefaults.standard.string(forKey: UserDefaultKeys.playerName) ?? "Player"
    }
    
    func goBack() {
        appModeStore.goBack()
    }
    
    func createRoom() {
        guard !playerName.isEmpty else {
            errorMessage = "Please enter your name"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let code = try await onlineGameService.createRoom(playerName: playerName)
                UserDefaults.standard.set(playerName, forKey: UserDefaultKeys.playerName)
                hapticService.triggerImpact(style: .medium)
                analyticsService.trackRoomAction(action: "create", method: "manual")
                isLoading = false
                appModeStore.goOnlineGame(roomID: code)
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    func joinRoom(method: String = "manual") {
        guard !playerName.isEmpty else {
            errorMessage = "Please enter your name"
            return
        }
        guard roomCode.count == 4 else {
            errorMessage = "Please enter a 4-digit code"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await onlineGameService.joinRoom(roomID: roomCode, playerName: playerName)
                UserDefaults.standard.set(playerName, forKey: UserDefaultKeys.playerName)
                hapticService.triggerImpact(style: .medium)
                analyticsService.trackRoomAction(action: "join", method: method)
                isLoading = false
                appModeStore.goOnlineGame(roomID: roomCode)
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}
