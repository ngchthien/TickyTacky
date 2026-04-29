//
//  ErrorHandlerService.swift
//  TickyTacky
//
//  Created by M1 Pro on 11/4/26.
//

import Foundation
import UIKit
import Factory
import FirebaseCrashlytics

protocol ErrorHandlerProtocol {
    func handle(_ error: GameError)
    func logError(_ error: GameError)
}

final class ErrorHandlerService: ErrorHandlerProtocol {
    @Injected(\.hapticService) private var hapticService
    @Injected(\.analyticsService) private var analyticsService
    @Injected(\.toastManager) private var toastManager

    func handle(_ error: GameError) {
        logError(error)
        
        // 1. Production Tracking (Firebase Analytics & Crashlytics)
        analyticsService.trackError(error.localizedDescription)
        Crashlytics.crashlytics().record(error: error)
        
        // 2. Physical Feedback
        hapticService.triggerNotification(type: .error)
        
        // 3. User Notification (Toast)
        toastManager.show(message: error.localizedDescription, type: .error)
    }
    
    func logError(_ error: GameError) {
        #if DEBUG
        print("🎮 Game Error: \(error.errorDescription ?? "Unknown Error")")
        #endif
    }
}
