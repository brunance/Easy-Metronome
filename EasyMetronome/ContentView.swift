//
//  ContentView.swift
//  EasyMetronome
//
//  Created by Bruno França do Prado on 04/10/25.
//

import SwiftUI

// MARK: - ContentView
struct ContentView: View {
    @StateObject private var metronome = MetronomeEngine()
    @State private var pulseAnimation = false
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack(spacing: 40) {
                Spacer()
                
                titleView
                bpmIndicator
                primaryControls
                secondaryControls
                bpmRangeLabel
                
                Spacer()
            }
        }
        .onChange(of: metronome.isPlaying) { oldValue, newValue in
            if newValue {
                startPulseAnimation()
            }
        }
    }
}

// MARK: - View Components
private extension ContentView {
    
    var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.1, green: 0.1, blue: 0.2),
                Color(red: 0.05, green: 0.05, blue: 0.15)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    var titleView: some View {
        Text("Metrônomo")
            .font(.system(size: 32, weight: .light, design: .rounded))
            .foregroundColor(.white.opacity(0.9))
    }
    
    var bpmIndicator: some View {
        ZStack {
            // Círculo de fundo com animação de pulso
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.3),
                            Color.purple.opacity(0.2)
                        ]),
                        center: .center,
                        startRadius: 50,
                        endRadius: 150
                    )
                )
                .frame(width: 280, height: 280)
                .scaleEffect(metronome.isPlaying && pulseAnimation ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 60.0 / Double(metronome.bpm)), value: pulseAnimation)
            
            // Círculo interno
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .frame(width: 260, height: 260)
            
            VStack(spacing: 8) {
                Text("\(metronome.bpm)")
                    .font(.system(size: 80, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("BPM")
                    .font(.system(size: 24, weight: .light, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
    
    var primaryControls: some View {
        HStack(spacing: 40) {
            controlButton(
                icon: "minus",
                action: { metronome.decreaseBPM() },
                isDisabled: metronome.bpm <= metronome.minBPM
            )
            
            playPauseButton
            
            controlButton(
                icon: "plus",
                action: { metronome.increaseBPM() },
                isDisabled: metronome.bpm >= metronome.maxBPM
            )
        }
    }
    
    var secondaryControls: some View {
        HStack(spacing: 20) {
            smallControlButton(
                label: "-10",
                action: { metronome.decreaseBPM(by: 10) },
                isDisabled: metronome.bpm <= metronome.minBPM
            )
            
            smallControlButton(
                label: "+10",
                action: { metronome.increaseBPM(by: 10) },
                isDisabled: metronome.bpm >= metronome.maxBPM
            )
        }
    }
    
    var bpmRangeLabel: some View {
        Text("\(metronome.minBPM) - \(metronome.maxBPM) BPM")
            .font(.system(size: 14, weight: .regular, design: .rounded))
            .foregroundColor(.white.opacity(0.5))
    }
    
    var playPauseButton: some View {
        Button(action: {
            metronome.togglePlayback()
            if metronome.isPlaying {
                triggerPulse()
            }
        }) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 90, height: 90)
                    .shadow(color: metronome.isPlaying ? Color.blue.opacity(0.6) : Color.clear, radius: 20)
                
                Image(systemName: metronome.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 35, weight: .semibold))
                    .foregroundColor(.white)
                    .offset(x: metronome.isPlaying ? 0 : 3)
            }
        }
    }
    
    func controlButton(icon: String, action: @escaping () -> Void, isDisabled: Bool) -> some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 70, height: 70)
                
                Image(systemName: icon)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.4 : 1.0)
    }
    
    func smallControlButton(label: String, action: @escaping () -> Void, isDisabled: Bool) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 80, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color.white.opacity(0.1))
                )
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.4 : 1.0)
    }
}

// MARK: - Animation Helpers
private extension ContentView {
    func triggerPulse() {
        pulseAnimation.toggle()
    }
    
    func startPulseAnimation() {
        Timer.scheduledTimer(withTimeInterval: 60.0 / Double(metronome.bpm), repeats: true) { timer in
            if metronome.isPlaying {
                triggerPulse()
            } else {
                timer.invalidate()
            }
        }
    }
}

#Preview {
    ContentView()
}
