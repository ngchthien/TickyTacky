//
//  GameResultView.swift
//  TickyTacky
//
//  Created by M1 Pro on 11/4/26.
//

import SwiftUI

struct GameResultView: View {
    let gameState: GameState
    let resetGame: () -> ()
    
    var body: some View {
        VStack(spacing: 24) {
            titleView
            
            if let winnerPlayer = gameState.winnerPlayer {
                winnerPlayerView(winnerPlayer)
            }
            
            playAgainButton
        }
        .padding()
        .infinityFrame()
        .background(Color.appTheme.viewBackground)
        .presentationDetents([.height(GameConstants.winnerSheetHeight)])
        .presentationCornerRadius(AppCornerRadius.overall.value)
        .presentationDragIndicator(.visible)
    }
}

private extension GameResultView {
    var titleView: some View {
        Text(gameState.isTied ? "🤝 It's a Tie!" : "🎉 Game Over!")
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(gameState.isTied ? Color.appTheme.alternateAccent : Color.appTheme.success)
    }
    
    func winnerPlayerView(_ winnerPlayer: Player) -> some View {
        HStack(spacing: 12) {
            Text("Winner:")
                .font(.title2)
                .foregroundStyle(Color.appTheme.secondaryText)
            
            Image(winnerPlayer.image)
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
            
            Text(winnerPlayer.cellSymbol.symbol)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(winnerPlayer.cellSymbol.color)
                .frame(width: 44, height: 44)
                .background(winnerPlayer.cellSymbol.color.opacity(0.15))
                .cornerRadius(AppCornerRadius.cell.value / 2)
        }
    }
    
    var playAgainButton: some View {
        Label("Play Again", systemImage: "arrow.counterclockwise.circle.fill")
            .primaryButton()
            .button(.press) {
                resetGame()
            }
    }
}

#Preview {
    VStack(spacing: 40) {
        GameResultView(gameState: .won(.defaultPlayer)) {}
        Divider()
        GameResultView(gameState: .tied) {}
    }
}
