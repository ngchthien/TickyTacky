//
//  QRCodeService.swift
//  TickyTacky
//
//  Created by Antigravity on 4/29/26.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

final class QRCodeService {
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()
    
    func generateQRCode(from string: String) -> UIImage? {
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        
        return nil
    }
}
