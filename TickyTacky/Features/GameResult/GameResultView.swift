//
//  GameResultView.swift
//  TickyTacky
//

import SwiftUI

struct GameResultView: View {
    let gameState: GameState
    let player1: Player
    let player2: Player
    let resetGame: () -> ()
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack(spacing: 32) {
                headerSection
                    .padding(.top, 56)
                
                if let winnerPlayer = gameState.winnerPlayer {
                    winnerCard(winnerPlayer)
                } else if gameState.isTied {
                    tieCard
                }
                
                Spacer()
                
                playAgainButton
                    .padding(.horizontal, 40)
                    .padding(.bottom, 34)
            }
            .infinityFrame()
        }
        .presentationDetents([.height(500)])
        .presentationCornerRadius(AppCornerRadius.overall.value * 2)
        .presentationDragIndicator(.visible)
    }
}

private extension GameResultView {
    var backgroundGradient: some View {
        ZStack {
            Color.appTheme.viewBackground.ignoresSafeArea()
            
            LinearGradient(
                colors: [
                    (gameState.isTied ? Color.appTheme.alternateAccent : Color.appTheme.success).opacity(0.15),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
    
    var headerSection: some View {
        VStack(spacing: 8) {
            Text(gameState.isTied ? "🤝" : "🏆")
                .font(.system(size: 60))
            
            Text(gameState.isTied ? "It's a Tie!" : "Victory!")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundStyle(Color.appTheme.text)
            
            Text(gameState.isTied ? "Great minds think alike." : "An legendary battle has ended.")
                .font(.subheadline)
                .foregroundStyle(Color.appTheme.secondaryText)
        }
    }
    
    func winnerCard(_ winner: Player) -> some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(winner.cellSymbol.color.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(winner.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .shadow(.regular)
            }
            
            VStack(spacing: 4) {
                Text(winner.profile.name.description)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appTheme.text)
                
                Text(winner.isBot ? "THE AI OVERLORD" : "THE CHAMPION")
                    .font(.caption2)
                    .fontWeight(.black)
                    .tracking(2)
                    .foregroundStyle(winner.cellSymbol.color)
            }
        }
        .padding(24)
        .background(Color.appTheme.cellBackground)
        .cornerRadius(.overall)
        .shadow(.regular)
    }
    
    var tieCard: some View {
        HStack(spacing: 32) {
            Image(player1.image)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .shadow(.light)
            
            Text("VS")
                .font(.headline)
                .fontWeight(.black)
                .foregroundStyle(Color.appTheme.secondaryText)
            
            Image(player2.image)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .shadow(.light)
        }
        .padding(24)
        .background(Color.appTheme.cellBackground)
        .cornerRadius(.overall)
        .shadow(.regular)
    }
    
    var playAgainButton: some View {
        HStack(spacing: 12) {
            Image(systemName: "arrow.counterclockwise.circle.fill")
            Text("Play Again")
        }
        .font(.headline)
        .fontWeight(.bold)
        .foregroundStyle(Color.appTheme.accentContrastText)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [Color.appTheme.accent, Color.appTheme.accent.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(.button)
        .shadow(.regular)
        .button(.press) {
            resetGame()
        }
    }
}

#Preview {
    GameResultView(gameState: .won(.defaultPlayer), player1: .defaultPlayer, player2: .defaultPlayer) {}
}
