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
    Group{
      switch viewModel.appMode {
      case .gameSetup:
       GameSetupView()
      case .game:
          GameView()
      }
    }
    .animation(.easeIn,value: viewModel.appMode)
    
  }
}

#Preview {
  AppModeView()
}
