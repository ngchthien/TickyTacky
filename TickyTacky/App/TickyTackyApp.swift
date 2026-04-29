//
//  TickyTackyApp.swift
//  TickyTacky
//
//  Created by M1 Pro on 6/4/26.
//

import SwiftUI
import FirebaseCore
import FirebaseDatabase

import Factory

@main
struct TickyTackyApp: App {
  @AppStorage(UserDefaultKeys.isDarkMode) private var isDarkMode: Bool = true
  @ObservedObject private var toastManager: ToastManager = Container.shared.toastManager()
  
  init() {
    FirebaseApp.configure()
    // Enable persistence once at the start
    Database.database(url: "https://ticky-tacky-ios-default-rtdb.firebaseio.com/").isPersistenceEnabled = true
    Database.database(url: "https://ticky-tacky-ios-default-rtdb.firebaseio.com/").goOnline()
  }
  var body: some Scene {
    WindowGroup {
      AppModeView()
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .overlay(alignment: .center) {
            if let toast = toastManager.currentToast {
                ToastView(toast: toast) {
                    toastManager.dismiss()
                }
                .transition(.scale(scale: 0.9).combined(with: .opacity))
                .zIndex(999)
            }
        }
    }
  }
}
