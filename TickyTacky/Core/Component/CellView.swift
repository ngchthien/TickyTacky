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
        Text(state.symbol)
            .font(.system(size: GameConstants.cellFontSize))
            .fontWeight(.bold)
            .foregroundStyle(state.color)
            .infinityFrame()
            .background(Color.appTheme.cellBackground)
            .cornerRadius(.cell)
            .overlay {
                RoundedRectangle(cornerRadius: AppCornerRadius.cell.value)
                    .stroke(Color.appTheme.success.opacity(isWinningCell ? 1 : 0), lineWidth: 3)
            }
            .aspectRatio(1, contentMode: .fit)
            .shadow(.light)
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
