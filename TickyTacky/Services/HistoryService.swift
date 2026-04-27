//
//  HistoryService.swift
//  TickyTacky
//
//  Created by Antigravity on 4/27/26.
//

import Foundation
import SwiftData

protocol HistoryServiceProtocol {
    @MainActor func saveMatch(_ match: MatchHistory)
    @MainActor func fetchAllMatches() -> [MatchHistory]
    @MainActor func clearHistory()
}

final class HistoryService: HistoryServiceProtocol {
    private let container: ModelContainer
    private let context: ModelContext

    @MainActor
    init() {
        do {
            container = try ModelContainer(for: MatchHistory.self)
            context = container.mainContext
        } catch {
            fatalError("Failed to initialize SwiftData ModelContainer: \(error)")
        }
    }

    @MainActor
    func saveMatch(_ match: MatchHistory) {
        context.insert(match)
        do {
            try context.save()
        } catch {
            print("Failed to save match history: \(error)")
        }
    }

    @MainActor
    func fetchAllMatches() -> [MatchHistory] {
        let descriptor = FetchDescriptor<MatchHistory>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Failed to fetch match history: \(error)")
            return []
        }
    }
    
    @MainActor
    func clearHistory() {
        do {
            try context.delete(model: MatchHistory.self)
        } catch {
            print("Failed to clear history: \(error)")
        }
    }
}
