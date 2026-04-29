//
//  ToastView.swift
//  TickyTacky
//
//  Created by Antigravity on 4/29/26.
//

import SwiftUI

struct ToastView: View {
    let toast: ToastItem
    let onDismiss: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: toast.type.icon)
                .foregroundStyle(.white)
                .font(.title3)
            
            Text(toast.message)
                .font(.subheadline.bold())
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
        .background(
            Capsule()
                .fill(toast.type.color)
                .shadow(color: toast.type.color.opacity(0.4), radius: 15, x: 0, y: 8)
        )
        .onTapGesture(perform: onDismiss)
    }
}
