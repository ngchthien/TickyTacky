//
//  TickyTackyApp.swift
//  TickyTacky
//
//  Created by M1 Pro on 6/4/26.
//

import SwiftUI
import FirebaseCore

@main
struct TickyTackyApp: App {
  @AppStorage(UserDefaultKeys.isDarkMode) private var isDarkMode: Bool = true
  
  init() {
    FirebaseApp.configure()
  }
  var body: some Scene {
    WindowGroup {
      AppModeView()
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
  }
}
