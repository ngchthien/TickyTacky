//
//  AppModeLiveStore.swift
//  TickyTacky
//
//  Created by M1 Pro on 7/4/26.
//

import Foundation
import Combine

@MainActor
final class AppModeLiveStore: ObservableObject {
  
  @Published private(set) var appMode: AppMode = .home
  private var modeStack: [AppMode] = [.home]
  
  private func updateMode(_ newMode: AppMode) {
    if appMode != newMode {
        modeStack.append(newMode)
        appMode = newMode
    }
  }

  func goHome() {
    modeStack = [.home]
    appMode = .home
  }
  
  func goGameMode() {
    updateMode(.game)
  }
  
  func goSetupMode() {
    updateMode(.gameSetup)
  }
  
  func goHistoryMode() {
    updateMode(.history)
  }
  
  func goSettingsMode() {
    updateMode(.settings)
  }
  
  func goOnlineLobby() {
    updateMode(.onlineLobby)
  }
  
  func goOnlineGame(roomID: String) {
    updateMode(.onlineGame(roomID))
  }
  
  func goLeaderboard() {
    updateMode(.leaderboard)
  }
  
  func goBack() {
    if modeStack.count > 1 {
        modeStack.removeLast()
        if let previous = modeStack.last {
            appMode = previous
        }
    } else if appMode != .home {
        goHome()
    }
  }
}
