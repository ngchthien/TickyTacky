//
//  GameSetupViewModel.swift
//  TickyTacky
//
//  Created by M1 Pro on 10/4/26.
//

import SwiftUI
import Combine
import Factory
@MainActor
final class GameSetupViewModel: ObservableObject {
    @Published var player1: PlayerProfile = .defaultPlayer1 {
        didSet { updatePlayer1(with: player1) }
    }
    
    @Published var player2: PlayerProfile = .defaultPlayer2 {
        didSet { updatePlayer2(with: player2) }
    }
    
    @Published var selectedDifficulty: Difficulty = .medium {
        didSet { updateDifficulty(with: selectedDifficulty) }
    }
    
    @Published var selectedFirstTurn: FirstTurn = .random {
        didSet { updateFirstTurn(with: selectedFirstTurn) }
    }
    @Injected(\.appModeStore) var appModeStore
    @Injected(\.gameSetupStore) var gameSetupStore
    
    init() {
        getSetupInfo()
    }
    
    func startGame() {
        appModeStore.appMode = .game
    }
    
    func goHistory() {
        appModeStore.goHistoryMode()
    }

    func goSettings() {
        appModeStore.goSettingsMode()
    }
}

private extension GameSetupViewModel {
    func getSetupInfo() {
        player1 = gameSetupStore.player1
        player2 = gameSetupStore.player2
        selectedDifficulty = gameSetupStore.selectedDifficulty
        selectedFirstTurn = gameSetupStore.selectedFirstTurn
    }
    
    func updatePlayer1(with player: PlayerProfile) {
        gameSetupStore.player1 = player
    }
    
    func updatePlayer2(with player: PlayerProfile) {
        gameSetupStore.player2 = player
    }
    
    func updateDifficulty(with difficulty: Difficulty) {
        gameSetupStore.selectedDifficulty = difficulty
    }
    
    func updateFirstTurn(with firstTurn: FirstTurn) {
        gameSetupStore.selectedFirstTurn = firstTurn
    }
}
