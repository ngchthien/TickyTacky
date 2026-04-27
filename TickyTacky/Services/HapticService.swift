//
//  HapticService.swift
//  TickyTacky
//
//  Created by Antigravity on 4/27/26.
//

import UIKit

protocol HapticServiceProtocol {
    func triggerImpact(style: UIImpactFeedbackGenerator.FeedbackStyle)
    func triggerNotification(type: UINotificationFeedbackGenerator.FeedbackType)
    func triggerSelection()
}

final class HapticService: HapticServiceProtocol {
    func triggerImpact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func triggerNotification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
    func triggerSelection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}
