//
//  AppModeLiveStore.swift
//  TickyTacky
//
//  Created by M1 Pro on 7/4/26.
//

import Foundation
import Combine

@MainActor
final class AppModeLiveStore: ObservableObject{
  
  @Published var appMode: AppMode = .home
  private var previousMode: AppMode = .home
  
  private func updateMode(_ newMode: AppMode) {
    if appMode != newMode {
        previousMode = appMode
        appMode = newMode
    }
  }

  func goHome()
  {
    updateMode(.home)
  }
  func goGameMode()
  {
    updateMode(.game)
  }
  func goSetupMode()
  {
    updateMode(.gameSetup)
  }
  func goHistoryMode()
  {
    updateMode(.history)
  }
  func goSettingsMode()
  {
    updateMode(.settings)
  }
  func goOnlineLobby()
  {
    updateMode(.onlineLobby)
  }
  func goOnlineGame(roomID: String)
  {
    updateMode(.onlineGame(roomID))
  }
  
  func goLeaderboard()
  {
    updateMode(.leaderboard)
  }
  
  func goBack() {
    appMode = previousMode
  }
}
