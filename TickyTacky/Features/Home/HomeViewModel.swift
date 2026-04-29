//
//  HomeViewModel.swift
//  TickyTacky
//
//  Created by Antigravity on 4/27/26.
//

import SwiftUI
import Factory
import Combine
@MainActor
final class HomeViewModel: ObservableObject {
    @Injected(\.appModeStore) private var appModeStore
    @Injected(\.hapticService) private var hapticService
    
    // Adding a dummy published property to ensure conformance in some Swift versions
    // though not strictly required, it helps with clarity.
    @Published var isLoading: Bool = false
    
    func playLocal() {
        hapticService.triggerImpact(style: .medium)
        appModeStore.goSetupMode()
    }
    
    func playOnline() {
        hapticService.triggerImpact(style: .medium)
        appModeStore.goOnlineLobby()
    }
    
    func goHistory() {
        appModeStore.goHistoryMode()
    }
    
    func goSettings() {
        appModeStore.goSettingsMode()
    }
}
