//
//  GameSetupView.swift
//  TickyTacky
//
//  Created by M1 Pro on 10/4/26.
//

import SwiftUI

struct GameSetupView: View {
    @AppStorage(UserDefaultKeys.isDarkMode) private var isDarkMode = true
    @StateObject private var viewModel = GameSetupViewModel()
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 20) {
                logoView
                welcomeText
                gameSetupSectionView
                Spacer()
                startBattleButton
            }
            .infinityFrame()
            .padding()
            .background(Color.appTheme.viewBackground)
            
            colorSchemeToggle
        }
    }
}

private extension GameSetupView {
    var startBattleButton: some View {
        HStack(spacing: 5) {
            Image(systemName: "flame")
            Text("Start Battle")
        }
        .font(.headline)
        .foregroundStyle(Color.appTheme.accentContrastText)
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.appTheme.accent)
        .cornerRadius(.button)
        .shadow(.regular)
        .button(.press) {
            viewModel.startGame()
        }
    }
    
    var logoView: some View {
        Image(.logo)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .foregroundStyle(Color.appTheme.accent)
    }
    
    var welcomeText: some View {
        VStack(spacing: 8) {
            Text("Ticky Tacky")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(Color.appTheme.accent)
            
            Text("- The One")
                .font(.caption)
                .foregroundStyle(Color.appTheme.secondaryText)
        }
    }
    
    var gameSetupSectionView: some View {
        VStack(spacing: 20) {
            PlayerSelectionView(
                player1: $viewModel.player1,
                player2: $viewModel.player2
            )
            
            SelectionGroupView(
                title: "Difficulty",
                options: Difficulty.allCases,
                selected: $viewModel.selectedDifficulty
            )
            
            SelectionGroupView(
                title: "Who goes first?",
                options: FirstTurn.allCases,
                selected: $viewModel.selectedFirstTurn
            )
        }
    }
}

private extension GameSetupView {
    var colorSchemeToggle: some View {
        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 20, height: 20)
            .foregroundStyle(isDarkMode ? Color.appTheme.alternateAccent : Color.appTheme.accent)
            .padding()
            .button(.press) {
                toggleColorScheme()
            }
    }
    
    func toggleColorScheme() {
        withAnimation(.default) {
            isDarkMode.toggle()
        }
    }
}

#Preview {
    GameSetupView()
}
