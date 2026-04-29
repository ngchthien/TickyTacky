//
//  ToastManager.swift
//  TickyTacky
//
//  Created by Antigravity on 4/29/26.
//

import SwiftUI
import Combine

enum ToastType {
    case info, success, warning, error
    
    var color: Color {
        switch self {
        case .info: return .blue
        case .success: return .green
        case .warning: return .orange
        case .error: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .info: return "info.circle.fill"
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .error: return "xmark.octagon.fill"
        }
    }
}

struct ToastItem: Identifiable, Equatable {
    let id = UUID()
    let message: String
    let type: ToastType
}

@MainActor
final class ToastManager: ObservableObject {
    @Published var currentToast: ToastItem?
    private var timer: AnyCancellable?
    
    func show(message: String, type: ToastType = .info) {
        // Cancel existing timer
        timer?.cancel()
        
        withAnimation(.spring()) {
            currentToast = ToastItem(message: message, type: type)
        }
        
        // Auto hide after 3 seconds
        timer = Just(())
            .delay(for: .seconds(3), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                withAnimation {
                    self?.currentToast = nil
                }
            }
    }
    
    func dismiss() {
        timer?.cancel()
        withAnimation {
            currentToast = nil
        }
    }
}
