//
//  GameBoardView.swift
//  TickyTacky
//
//  Created by M1 Pro on 11/4/26.
//

import SwiftUI

struct GameBoardView: View {
    let board: [CellState]
    let winningCells: Set<Int>
    var suggestedCell: Int? = nil
    let onCellTap: (Int) -> Void
    
    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: GameConstants.boardSpacing),
        count: GameConstants.boardSize
    )
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: GameConstants.boardSpacing) {
            ForEach(0..<board.count, id: \.self) { index in
                CellView(
                    state: board[index],
                    isWinningCell: winningCells.contains(index),
                    isSuggested: suggestedCell == index
                )
                .button(.press) {
                    onCellTap(index)
                }
            }
        }
    }
}

#Preview {
    GameBoardView(
        board: Array(repeating: .empty, count: 9),
        winningCells: [],
        onCellTap: { _ in }
    )
    .padding()
    .background(Color.appTheme.viewBackground)
}
