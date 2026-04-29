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
            if viewModel.navigationPath.contains(.privateJoin) {
                destinationView(for: .privateJoin)
                    .transition(.move(edge: .trailing))
            } else {
                ZStack {
                    backgroundGradient
                    
                    VStack(spacing: 0) {
                        headerView
                        
                        ScrollView {
                            VStack(spacing: 24) {
                                profileSection
                                
                                VStack(spacing: 20) {
                                    menuCard(
                                        title: AppStrings.createGame,
                                        subtitle: AppStrings.hostOwnMatch,
                                        icon: "plus.circle.fill",
                                        gradient: [Color.appTheme.success, Color.appTheme.success.opacity(0.8)],
                                        action: { viewModel.createRoom() }
                                    )
                                    
                                    menuCard(
                                        title: AppStrings.joinGame,
                                        subtitle: AppStrings.joinViaCode,
                                        icon: "key.fill",
                                        gradient: [Color(hex: "334155"), Color(hex: "1E293B")],
                                        action: { viewModel.navigateTo(.privateJoin) }
                                    )
                                }
                            }
                            .padding(24)
                        }
                    }
                }
                .transition(.move(edge: .leading))
            }
            
            if viewModel.isLoading {
                loadingOverlay
            }
        }
        .infinityFrame()
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: viewModel.navigationPath)
        .sheet(isPresented: $viewModel.showScanner) {
            scannerSheet
        }
    }
}

private extension OnlineLobbyView {
    var backgroundGradient: some View {
        Color.appTheme.viewBackground.ignoresSafeArea()
    }
    
    var headerView: some View {
        HStack {
            Button(action: { 
                if !viewModel.navigationPath.isEmpty {
                    viewModel.goBack()
                } else {
                    viewModel.goBack()
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.title3.bold())
                    .foregroundStyle(Color.appTheme.text)
                    .padding(12)
                    .background(Color.appTheme.cellBackground)
                    .clipShape(Circle())
                    .shadow(.light)
            }
            
            Spacer()
            
            Text(AppStrings.onlineBattle)
                .font(.title2.weight(.black))
                .foregroundStyle(Color.appTheme.text)
            
            Spacer()
            
            // Empty placeholder for balance
            Circle()
                .fill(.clear)
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal)
        .padding(.top, 12)
    }
    
    var profileSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(AppStrings.yourProfile)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.appTheme.secondaryText)
                .tracking(2)
            
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.appTheme.accent.opacity(0.1))
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: "person.fill")
                        .font(.title)
                        .foregroundStyle(Color.appTheme.accent)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    TextField(AppStrings.enterName, text: $viewModel.playerName)
                        .font(.title3.bold())
                        .foregroundStyle(Color.appTheme.text)
                    
                    Text("Ready for battle")
                        .font(.caption)
                        .foregroundStyle(Color.appTheme.secondaryText)
                }
            }
            .padding()
            .background(Color.appTheme.cellBackground)
            .cornerRadius(.overall)
            .shadow(.light)
        }
    }
    
    func menuCard(title: String, subtitle: String, icon: String, gradient: [Color], action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(gradient: Gradient(colors: gradient), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline.bold())
                        .foregroundStyle(Color.appTheme.text)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color.appTheme.secondaryText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(Color.appTheme.secondaryText.opacity(0.5))
            }
            .padding(20)
            .background(Color.appTheme.cellBackground)
            .cornerRadius(.overall)
            .shadow(.regular)
        }
        .button(.press) {}
    }
    
    var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.5)
                
                Text("Connecting...")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .padding(32)
            .background(.ultraThinMaterial)
            .cornerRadius(.overall)
        }
    }
    
    @ViewBuilder
    func destinationView(for destination: OnlineLobbyViewModel.OnlineLobbyDestination) -> some View {
        switch destination {
        case .privateJoin:
            privateJoinScreen
        }
    }
    
    var privateJoinScreen: some View {
        ZStack {
            backgroundGradient
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { viewModel.goBack() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3.bold())
                            .foregroundStyle(Color.appTheme.text)
                            .padding(12)
                            .background(Color.appTheme.cellBackground)
                            .clipShape(Circle())
                    }
                    Spacer()
                    Text(AppStrings.joinRoom)
                        .font(.headline.bold())
                    Spacer()
                    Circle().fill(.clear).frame(width: 44)
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Room Code Input
                        VStack(alignment: .leading, spacing: 12) {
                            Text(AppStrings.enterRoomCode)
                                .font(.caption.bold())
                                .foregroundStyle(Color.appTheme.secondaryText)
                                .tracking(1)
                            
                            TextField("0000", text: $viewModel.roomCode)
                                .font(.system(size: 48, weight: .black, design: .monospaced))
                                .multilineTextAlignment(.center)
                                .keyboardType(.numberPad)
                                .padding(.vertical, 24)
                                .background(Color.appTheme.cellBackground)
                                .cornerRadius(.overall)
                                .shadow(.light)
                                .onChange(of: viewModel.roomCode) { newValue in
                                    if newValue.count > 4 {
                                        viewModel.roomCode = String(newValue.prefix(4))
                                    }
                                }
                        }
                        
                        Button(action: { viewModel.joinRoom() }) {
                            Text(AppStrings.joinNow)
                                .font(.headline.bold())
                                .foregroundStyle(Color.appTheme.accentContrastText)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.appTheme.accent)
                                .cornerRadius(.button)
                                .shadow(.regular)
                        }
                        .disabled(viewModel.roomCode.count != 4)
                        .opacity(viewModel.roomCode.count == 4 ? 1 : 0.6)
                        
                        HStack {
                            Rectangle().fill(Color.appTheme.secondaryText.opacity(0.2)).frame(height: 1)
                            Text(AppStrings.or).font(.caption.bold()).foregroundStyle(Color.appTheme.secondaryText).padding(.horizontal)
                            Rectangle().fill(Color.appTheme.secondaryText.opacity(0.2)).frame(height: 1)
                        }
                        
                        Button(action: { viewModel.showScanner = true }) {
                            HStack {
                                Image(systemName: "qrcode.viewfinder")
                                Text(AppStrings.scanQRCode)
                            }
                            .font(.headline.bold())
                            .foregroundStyle(Color.appTheme.accent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.appTheme.accent.opacity(0.1))
                            .cornerRadius(.button)
                        }
                    }
                    .padding(24)
                }
            }
            
            if let error = viewModel.errorMessage {
                VStack {
                    Spacer()
                    Text(error)
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                        .padding(.bottom, 40)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation { viewModel.errorMessage = nil }
                    }
                }
            }
        }
    }
    
    var scannerSheet: some View {
        VStack(spacing: 20) {
            HStack {
                Text(AppStrings.scanQRCode)
                    .font(.title3.bold())
                Spacer()
                Button(action: { viewModel.showScanner = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.appTheme.secondaryText)
                }
            }
            .padding()
            
            // Scanner implementation...
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black)
                    .overlay(
                        Text("Camera Preview Placeholder")
                            .foregroundStyle(.white)
                    )
                
                // Corner marks
                VStack {
                    HStack {
                        scannerCorner(rotation: 0)
                        Spacer()
                        scannerCorner(rotation: 90)
                    }
                    Spacer()
                    HStack {
                        scannerCorner(rotation: -90)
                        Spacer()
                        scannerCorner(rotation: 180)
                    }
                }
                .padding(60)
            }
            .aspectRatio(1, contentMode: .fit)
            .padding()
            
            Text(AppStrings.alignQR)
                .font(.caption)
                .foregroundStyle(Color.appTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    func scannerCorner(rotation: Double) -> some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color.appTheme.accent)
            .frame(width: 40, height: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.appTheme.accent)
                    .frame(width: 4, height: 40),
                alignment: .topLeading
            )
            .rotationEffect(.degrees(rotation))
    }
}
