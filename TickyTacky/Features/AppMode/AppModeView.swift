//
//  ContentView.swift
//  TickyTacky
//
//  Created by M1 Pro on 6/4/26.
//

import SwiftUI

struct AppModeView: View {
  
  @StateObject private var viewModel = AppModeViewModel()
  var body: some View {
    NavigationStack {
      Group {
        switch viewModel.appMode {
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
        }
      }
      .animation(.easeIn, value: viewModel.appMode)
    }
    
  }
}

#Preview {
  AppModeView()
}
