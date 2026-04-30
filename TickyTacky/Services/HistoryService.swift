//
//  HistoryService.swift
//  TickyTacky
//
//  Created by Antigravity on 4/27/26.
//

import Foundation
import SwiftData

protocol HistoryServiceProtocol {
    func saveMatch(_ match: MatchHistory) async
    func fetchAllMatches() async -> [MatchHistory]
    func clearHistory() async
}

final class HistoryService: HistoryServiceProtocol {
    private let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: MatchHistory.self)
        } catch {
            fatalError("Failed to initialize SwiftData ModelContainer: \(error)")
        }
    }

    @MainActor
    func saveMatch(_ match: MatchHistory) async {
        let context = container.mainContext
        context.insert(match)
        do {
            try context.save()
        } catch {
            print("Failed to save match history: \(error)")
        }
    }

    @MainActor
    func fetchAllMatches() async -> [MatchHistory] {
        let context = container.mainContext
        let descriptor = FetchDescriptor<MatchHistory>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Failed to fetch match history: \(error)")
            return []
        }
    }
    
    @MainActor
    func clearHistory() async {
        let context = container.mainContext
        do {
            try context.delete(model: MatchHistory.self)
            try context.save()
        } catch {
            print("Failed to clear history: \(error)")
        }
    }
}
