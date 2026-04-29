//
//  LeaderboardViewModel.swift
//  TickyTacky
//
//  Created by Antigravity on 4/29/26.
//

import SwiftUI
import Factory
import Combine

@MainActor
final class LeaderboardViewModel: ObservableObject {
    @Published var entries: [LeaderboardEntry] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    @Injected(\.leaderboardService) private var leaderboardService
    @Injected(\.appModeStore) private var appModeStore
    @Injected(\.hapticService) var hapticService
    
    init() {
        fetchScores()
    }
    
    func goHome() {
        hapticService.triggerImpact(style: .light)
        appModeStore.goHome()
    }
    
    func fetchScores() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                self.entries = try await leaderboardService.fetchTopScores(limit: 20)
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}
