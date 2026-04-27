//
//  SettingsViewModel.swift
//  TickyTacky
//
//  Created by Antigravity on 4/27/26.
//

import SwiftUI
import Combine
import Factory

@MainActor
final class SettingsViewModel: ObservableObject {
    @AppStorage(UserDefaultKeys.isDarkMode) var isDarkMode = true
    @AppStorage("isHapticEnabled") var isHapticEnabled = true
    
    @Injected(\.appModeStore) private var appModeStore
    
    init() {}
    
    func goBack() {
        appModeStore.goSetupMode()
    }
    
    func openSystemSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
