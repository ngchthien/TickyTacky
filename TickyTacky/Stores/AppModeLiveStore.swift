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
  
  @Published  var appMode:AppMode = .gameSetup
  
  func goGameMode()
  {
    appMode = .game
  }
  func goSetupMode()
  {
    appMode = .gameSetup
  }
  func goHistoryMode()
  {
    appMode = .history
  }
}
