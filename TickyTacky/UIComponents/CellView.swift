//
//  CellView.swift
//  TickyTacky
//
//  Created by M1 Pro on 11/4/26.
//

import SwiftUI

struct CellView: View {
    let state: CellState
    let isWinningCell: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppCornerRadius.cell.value)
                .fill(Color.appTheme.cellBackground)
                .shadow(.light)
            
            markerView
        }
        .aspectRatio(1, contentMode: .fit)
        .overlay {
            RoundedRectangle(cornerRadius: AppCornerRadius.cell.value)
                .stroke(Color.appTheme.success.opacity(isWinningCell ? 0.8 : 0), lineWidth: 3)
                .blur(radius: isWinningCell ? 2 : 0)
        }
        .scaleEffect(isWinningCell ? 1.05 : 1.0)
        .animation(.spring(duration: 0.4), value: isWinningCell)
    }
    
    @ViewBuilder
    private var markerView: some View {
        switch state {
        case .x:
            Image(systemName: "xmark")
                .font(.system(size: GameConstants.cellFontSize, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.appTheme.accent, Color.appTheme.accent.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.appTheme.accent.opacity(0.3), radius: 4, x: 0, y: 2)
        case .o:
            Image(systemName: "circle")
                .font(.system(size: GameConstants.cellFontSize, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.appTheme.alternateAccent, Color.appTheme.alternateAccent.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.appTheme.alternateAccent.opacity(0.3), radius: 4, x: 0, y: 2)
        case .empty:
            EmptyView()
        }
    }
}

#Preview {
    Preview()
}

fileprivate struct Preview: View {
    var body: some View {
        HStack(spacing: GameConstants.boardSpacing) {
            CellView(state: .x, isWinningCell: false)
            CellView(state: .o, isWinningCell: true)
            CellView(state: .x, isWinningCell: false)
        }
        .padding()
        .background(Color.appTheme.viewBackground)
    }
}
