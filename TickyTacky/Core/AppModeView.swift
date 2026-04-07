//
//  ContentView.swift
//  TickyTacky
//
//  Created by M1 Pro on 6/4/26.
//

import SwiftUI

struct AppModeView: View {
  
  @StateObject private var viewModel = AppModelViewModel()
  var body: some View {
    Group{
      switch viewModel.appMode {
      case .gameSetup:
        Text("Game Setup")
      case .game:
          Text("Game")
      }
    }
    .animation(.easeIn,value: viewModel.appMode)
    
  }
}

#Preview {
  AppModeView()
}
