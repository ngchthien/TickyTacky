//
//  ConfettiView.swift
//  TickyTacky
//
//  Created by Antigravity on 4/27/26.
//

import SwiftUI

struct ConfettiView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: -10)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: UIScreen.main.bounds.width, height: 1)
        
        let colors: [UIColor] = [.systemRed, .systemBlue, .systemGreen, .systemYellow, .systemPink, .systemPurple, .systemOrange]
        
        let cells: [CAEmitterCell] = colors.map { color in
            let cell = CAEmitterCell()
            cell.birthRate = 10
            cell.lifetime = 10.0
            cell.velocity = CGFloat.random(in: 150...300)
            cell.velocityRange = 50
            cell.emissionLongitude = .pi
            cell.emissionRange = .pi / 4
            cell.spin = 3
            cell.spinRange = 2
            cell.scale = 0.1
            cell.scaleRange = 0.05
            cell.contents = createConfettiImage(color: color)?.cgImage
            return cell
        }
        
        emitter.emitterCells = cells
        view.layer.addSublayer(emitter)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    private func createConfettiImage(color: UIColor) -> UIImage? {
        let size = CGSize(width: 12, height: 12)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        color.setFill()
        
        // Randomly choose between a square and a circle for confetti
        if Bool.random() {
            context?.fill(CGRect(origin: .zero, size: size))
        } else {
            context?.fillEllipse(in: CGRect(origin: .zero, size: size))
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
