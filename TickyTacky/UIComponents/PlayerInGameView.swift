//
//  PlayerInGameView.swift
//  TickyTacky
//
//  Created by M1 Pro on 11/4/26.
//

import SwiftUI

struct PlayerInGameView: View {
    let player: PlayerProfile
    let orientation: Orientation
    let isCurrentPlayer: Bool
    let winsCount: Int
    
    @State private var animateArrows = false
    
    var body: some View {
        VStack(spacing: 2) {
            arrowIndicatorView
            
            HStack(spacing: 8) {
                switch orientation {
                case .left:
                    imageView
                    detailsView
                case .right:
                    detailsView
                    imageView
                }
            }
            .padding(12)
            .background(Color.appTheme.cellBackground)
            .cornerRadius(.cell)
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.cell.value)
                    .stroke(Color.appTheme.accent.opacity(isCurrentPlayer ? 1 : 0), lineWidth: 2)
            )
        }
        .onAppear {
            updateAnimateArrowsAnimation(isCurrentPlayer: isCurrentPlayer)
        }
        .onChange(of: isCurrentPlayer) { _, newValue in
            updateAnimateArrowsAnimation(isCurrentPlayer: newValue)
        }
    }
}

private extension PlayerInGameView {
    var arrowIndicatorView: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { i in
                Image(systemName: "chevron.down")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appTheme.accent)
                    .opacity(isCurrentPlayer ? (animateArrows ? 1 : 0.3) : 0)
                    .offset(y: animateArrows ? 2 : -2)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever(autoreverses: true)
                        .delay(Double(i) * 0.1),
                        value: animateArrows
                    )
            }
        }
    }
    
    func updateAnimateArrowsAnimation(isCurrentPlayer: Bool) {
        withAnimation {
            animateArrows = isCurrentPlayer
        }
    }
    
    var imageView: some View {
        Image(player.image)
            .resizable()
            .scaledToFit()
            .frame(width: 48, height: 48)
            .padding(4)
            .background(Color(.systemGray6))
            .cornerRadius(.overall)
    }
    
    var detailsView: some View {
        VStack(alignment: orientation == .left ? .leading : .trailing, spacing: 2) {
            Text(player.name.description)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(isCurrentPlayer ? Color.appTheme.accent : Color.appTheme.text)
            
            HStack(spacing: 4) {
                if orientation == .right {
                    Text("\(winsCount)")
                    symbolView
                } else {
                    symbolView
                    Text("\(winsCount)")
                }
            }
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundStyle(Color.appTheme.secondaryText)
        }
        .frame(minWidth: 60, alignment: orientation == .left ? .leading : .trailing)
    }
    
    @ViewBuilder
    var symbolView: some View {
        if orientation == .left {
            Image(systemName: "xmark")
                .foregroundStyle(Color.appTheme.accent)
        } else {
            Image(systemName: "circle")
                .foregroundStyle(Color.appTheme.alternateAccent)
        }
    }
}

extension PlayerInGameView {
    enum Orientation {
        case left, right
    }
}

#Preview {
    HStack {
        PlayerInGameView(
            player: .defaultPlayer1,
            orientation: .left,
            isCurrentPlayer: true,
            winsCount: 2
        )
        
        Spacer()
        
        PlayerInGameView(
            player: .defaultPlayer2,
            orientation: .right,
            isCurrentPlayer: false,
            winsCount: 1
        )
    }
    .padding()
    .background(Color.appTheme.viewBackground)
}
