//
//  OnlineLobbyView.swift
//  TickyTacky
//
//  Created by Antigravity on 4/27/26.
//

import SwiftUI

struct OnlineLobbyView: View {
    @StateObject private var viewModel = OnlineLobbyViewModel()
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack(spacing: 32) {
                headerView
                
                ScrollView {
                    VStack(spacing: 32) {
                        profileSection
                        hostSection
                        joinSection
                    }
                    .padding()
                }
            }
            
            if viewModel.isLoading {
                loadingOverlay
            }
        }
        .infinityFrame()
        .sheet(isPresented: $viewModel.showScanner) {
            scannerSheet
        }
    }
}

private extension OnlineLobbyView {
    var backgroundGradient: some View {
        ZStack {
            Color.appTheme.viewBackground.ignoresSafeArea()
            LinearGradient(
                colors: [Color.appTheme.accent.opacity(0.1), Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ).ignoresSafeArea()
        }
    }
    
    var headerView: some View {
        HStack {
            Button(action: viewModel.goBack) {
                Image(systemName: "chevron.left")
                    .font(.title3.bold())
                    .foregroundStyle(Color.appTheme.text)
                    .frame(width: 44, height: 44)
                    .background(Color.appTheme.cellBackground)
                    .clipShape(Circle())
                    .shadow(.light)
            }
            .button(.press) {}
            
            Spacer()
            Text("Online Battle")
                .font(.title2.bold())
                .foregroundStyle(Color.appTheme.text)
            Spacer()
            
            Circle().fill(Color.clear).frame(width: 44)
        }
        .padding()
    }
    
    var profileSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("YOUR PROFILE")
                .font(.caption.bold())
                .foregroundStyle(Color.appTheme.secondaryText)
            
            TextField("Enter your name", text: $viewModel.playerName)
                .padding()
                .background(Color.appTheme.cellBackground)
                .cornerRadius(.overall)
                .shadow(.light)
        }
    }
    
    var hostSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("HOST A GAME")
                .font(.caption.bold())
                .foregroundStyle(Color.appTheme.secondaryText)
            
            Button(action: viewModel.createRoom) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Create New Room")
                }
                .font(.headline)
                .foregroundStyle(Color.appTheme.accentContrastText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.appTheme.accent)
                .cornerRadius(.button)
                .shadow(.regular)
            }
            .button(.press) {}
            
            Text("Share the 4-digit code with your friend to start playing.")
                .font(.caption)
                .foregroundStyle(Color.appTheme.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
    }
    
    var joinSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("JOIN A GAME")
                .font(.caption.bold())
                .foregroundStyle(Color.appTheme.secondaryText)
            
            HStack(spacing: 12) {
                TextField("Code (e.g. 1234)", text: $viewModel.roomCode)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.title3.bold())
                    .padding()
                    .background(Color.appTheme.cellBackground)
                    .cornerRadius(.overall)
                    .shadow(.light)
                
                Button(action: {
                    viewModel.showScanner = true
                    viewModel.hapticService.triggerImpact(style: .light)
                }) {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.title2)
                        .foregroundStyle(Color.appTheme.accent)
                        .padding(16)
                        .background(Color.appTheme.accent.opacity(0.1))
                        .clipShape(Circle())
                }
                
                Button(action: viewModel.joinRoom) {
                    Text("Join")
                        .font(.headline)
                        .foregroundStyle(Color.appTheme.accentContrastText)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 18)
                        .background(Color.appTheme.alternateAccent)
                        .cornerRadius(.button)
                        .shadow(.regular)
                }
                .button(.press) {}
            }
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()
            ProgressView()
                .padding(24)
                .background(Color.appTheme.cellBackground)
                .cornerRadius(.overall)
        }
    }
    
    var scannerSheet: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Scan Room QR Code")
                    .font(.headline)
                Spacer()
                Button(action: { viewModel.showScanner = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.appTheme.secondaryText)
                }
            }
            .padding()
            
            ZStack {
                QRScannerView { code in
                    // Extract code from full string if it's formatted like "Room Code: 1234"
                    let filteredCode = code.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                    let finalCode = String(filteredCode.suffix(4))
                    
                    if finalCode.count == 4 {
                        viewModel.roomCode = finalCode
                        viewModel.showScanner = false
                        viewModel.joinRoom()
                    }
                }
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.appTheme.accent, lineWidth: 4)
                        .frame(width: 250, height: 250)
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Text("Align the QR code within the frame to join automatically.")
                .font(.caption)
                .foregroundStyle(Color.appTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding()
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    OnlineLobbyView()
}
