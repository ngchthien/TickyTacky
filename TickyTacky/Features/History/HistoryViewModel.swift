//
//  HistoryViewModel.swift
//  TickyTacky
//
//  Created by Antigravity on 4/27/26.
//

import Foundation
import Combine
import Factory

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var matches: [MatchHistory] = []
    
    @Injected(\.historyService) private var historyService
    @Injected(\.appModeStore) private var appModeStore
    
    init() {
        loadHistory()
    }
    
    func loadHistory() {
        matches = historyService.fetchAllMatches()
    }
    
    func clearHistory() {
        historyService.clearHistory()
        matches = []
    }
    
    func goBack() {
        appModeStore.goSetupMode()
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let seconds = Int(duration)
        if seconds < 60 {
            return "\(seconds)s"
        } else {
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            return "\(minutes)m \(remainingSeconds)s"
        }
    }
}
