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
class OnlineLobbyViewModel: ObservableObject {
    @Published var playerName: String = ""
    @Published var roomCode: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showScanner: Bool = false
    @Published var navigationPath: [OnlineLobbyDestination] = []
    @Published var publicRooms: [GameRoom] = []
    
    enum OnlineLobbyDestination: Hashable {
        case privateJoin
    }
    
    private var currentPlayerID: String?
    private var observeTask: Task<Void, Never>?
    
    @Injected(\.appModeStore) private var appModeStore
    @Injected(\.onlineGameService) private var onlineGameService
    @Injected(\.hapticService) var hapticService
    @Injected(\.analyticsService) private var analyticsService
    @Injected(\.toastManager) private var toastManager
    
    init() {
        self.playerName = UserDefaults.standard.string(forKey: UserDefaultKeys.playerName) ?? "Player"
        observePublicRooms()
    }
    
    deinit {
        observeTask?.cancel()
    }
    
    private func observePublicRooms() {
        observeTask?.cancel()
        observeTask = Task {
            for await rooms in onlineGameService.observePublicRoomsStream() {
                self.publicRooms = rooms
            }
        }
    }
    
    func goBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        } else {
            appModeStore.goBack()
        }
    }
    
    func navigateTo(_ destination: OnlineLobbyDestination) {
        navigationPath.append(destination)
    }
    
    func createRoom() {
        createPublicRoom(isPublic: false)
    }
    
    func createPublicRoom(isPublic: Bool) {
        guard !playerName.isEmpty else {
            errorMessage = AppStrings.enterNameError
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let result = try await onlineGameService.createRoom(playerName: playerName, isPublic: isPublic)
                self.currentPlayerID = result.playerID
                UserDefaults.standard.set(result.playerID, forKey: "online_player_id")
                UserDefaults.standard.set(playerName, forKey: UserDefaultKeys.playerName)
                hapticService.triggerImpact(style: .medium)
                analyticsService.trackRoomAction(action: "create", method: isPublic ? "public" : "private")
                isLoading = false
                appModeStore.goOnlineGame(roomID: result.roomID)
            } catch let error as OnlineGameError {
                errorMessage = error.errorDescription
                toastManager.show(message: error.errorDescription ?? "Lỗi không xác định", type: .error)
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                toastManager.show(message: error.localizedDescription, type: .error)
                isLoading = false
            }
        }
    }
    
    func joinRoom(method: String = "manual") {
        guard !playerName.isEmpty else {
            errorMessage = AppStrings.enterNameError
            return
        }
        guard roomCode.count == 4 else {
            errorMessage = AppStrings.enterCodeError
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let playerID = try await onlineGameService.joinRoom(roomID: roomCode, playerName: playerName)
                self.currentPlayerID = playerID
                UserDefaults.standard.set(playerID, forKey: "online_player_id")
                UserDefaults.standard.set(playerName, forKey: UserDefaultKeys.playerName)
                hapticService.triggerImpact(style: .medium)
                analyticsService.trackRoomAction(action: "join", method: method)
                
                // Ensure UI updates on main thread and after a tiny delay to allow Firebase to settle
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
                
                self.isLoading = false
                self.appModeStore.goOnlineGame(roomID: self.roomCode)
            } catch let error as OnlineGameError {
                errorMessage = error.errorDescription
                toastManager.show(message: error.errorDescription ?? "Lỗi không xác định", type: .error)
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                toastManager.show(message: error.localizedDescription, type: .error)
                isLoading = false
            }
        }
    }
    
    func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
        hapticService.triggerNotification(type: .success)
        toastManager.show(message: AppStrings.copied, type: .success)
    }
}
