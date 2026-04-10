//
//  GameSetupLiveStore.swift
//  TickyTacky
//
//  Created by Raul Gutierrez Niubo on 9/20/25.
//

import Foundation
import Combine

@MainActor
final class GameSetupLiveStore: ObservableObject {
    @Published var player1: PlayerProfile = .defaultPlayer1
    @Published var player2: PlayerProfile = .defaultPlayer2
    @Published var selectedDifficulty: Difficulty = .medium
    @Published var selectedFirstTurn: FirstTurn = .random
}
