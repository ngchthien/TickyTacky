//
//  SelectionGroupView.swift
//  TickyTacky
//
//  Created by M1 Pro on 10/4/26.
//

import SwiftUI

struct SelectionGroupView<Option: Hashable & CustomStringConvertible>: View {
    let title: String
    let options: [Option]
    @Binding var selected: Option
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            titleView
            optionsView
        }
    }
}

private extension SelectionGroupView {
    var titleView: some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(Color.appTheme.info)
    }
    
    var optionsView: some View {
        HStack(spacing: 8) {
            ForEach(options, id: \.self) { option in
                optionView(for: option)
                    .button(.press) {
                        selectOption(option)
                    }
            }
        }
    }
    
    func optionView(for option: Option) -> some View {
        let isSelected = selected == option
        return Text(option.description)
            .fontWeight(.medium)
            .foregroundStyle(isSelected ? Color.appTheme.accentContrastText : Color.appTheme.secondaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.appTheme.info.opacity(0.6) : Color.appTheme.info.opacity(0.2))
            .cornerRadius(.button)
            .shadow(.light)
    }
    
    func selectOption(_ option: Option) {
        withAnimation(.spring()) {
            selected = option
        }
    }
}

#Preview {
    Preview()
}

fileprivate struct Preview: View {
    @State private var selectedDifficulty: Difficulty = .hard
    
    var body: some View {
        SelectionGroupView(
            title: "Difficulty",
            options: Difficulty.allCases,
            selected: $selectedDifficulty
        )
        .infinityFrame()
        .padding()
        .background(Color.appTheme.viewBackground)
    }
}
