//
//  ContentView.swift
//  TickyTacky
//
//  Created by M1 Pro on 6/4/26.
//

import SwiftUI
import Factory

struct AppModeView: View {
  @ObservedObject private var store: AppModeLiveStore = Container.shared.appModeStore()
  @AppStorage(UserDefaultKeys.isDarkMode) private var isDarkMode: Bool = true
  
  var body: some View {
    NavigationStack {
        Group {
          switch store.appMode {
          case .home:
            HomeView()
          case .gameSetup:
            GameSetupView()
          case .game:
            GameView()
          case .history:
            HistoryView()
          case .settings:
            SettingsView()
          case .onlineLobby:
            OnlineLobbyView()
          case .onlineGame(let roomID):
            OnlineGameView(roomID: roomID)
          case .leaderboard:
            LeaderboardView()
          }
        }
        .animation(.easeIn(duration: 0.2), value: store.appMode)
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
  }
}

#Preview {
  AppModeView()
}
