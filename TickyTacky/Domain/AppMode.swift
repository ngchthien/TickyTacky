//
//  AppMode.swift
//  TickyTacky
//
//  Created by M1 Pro on 7/4/26.
//

enum AppMode: Equatable {
  case home
  case gameSetup
  case game
  case history
  case settings
  case onlineLobby
  case onlineGame(String)
}
