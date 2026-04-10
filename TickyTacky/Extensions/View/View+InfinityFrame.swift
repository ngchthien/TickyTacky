//
//  View+InfinityFrame.swift
//  TickyTacky
//
//  Created by M1 Pro on 7/4/26.
//

import SwiftUI

extension View {
    func infinityFrame() -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
