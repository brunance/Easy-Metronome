//
//  MetronomeView.swift
//  EasyMetronome
//
//  Created by Bruno França do Prado on 04/10/25.
//

import SwiftUI

// MARK: - ContentView
struct MetronomeView: View {
    @StateObject private var metronome = MetronomeEngine()
    @State private var pulseAnimation = false
    @State private var beatFlash = false
    @State private var animationTimer: Timer?
    @State private var currentTheme: AppTheme = .light
    @State private var showTimeSignaturePicker = false

    private var theme: ThemeColors {
        currentTheme.colors
    }

    var body: some View {
        ZStack {
            theme.background
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                titleView
                timeSignatureSelector
                bpmIndicator
                beatIndicator
                primaryControls
                secondaryControls
                bpmRangeLabel

                Spacer()
            }

            // Botão de tema no canto superior direito
            VStack {
                HStack {
                    Spacer()
                    themeButton
                        .padding(.top, 50)
                        .padding(.trailing, 20)
                }
                Spacer()
            }
        }
        .onChange(of: metronome.isPlaying) {
            if metronome.isPlaying {
                startPulseAnimation()
            } else {
                stopPulseAnimation()
            }
        }
        .onChange(of: metronome.bpm) {
            if metronome.isPlaying {
                restartPulseAnimation()
            }
        }
    }
}

// MARK: - View Components
private extension MetronomeView {

    var titleView: some View {
        Text("EasyMetronome")
            .font(.system(size: 32, weight: .light, design: .rounded))
            .foregroundColor(theme.title)
    }

    var timeSignatureSelector: some View {
        Button {
            showTimeSignaturePicker = true
        } label: {
            HStack(spacing: 8) {
                Text(metronome.timeSignature.description)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(theme.buttonIcon)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(theme.buttonFill.opacity(0.8))
            )
        }
        .buttonStyle(.plain)
        .confirmationDialog("Selecione o Compasso", isPresented: $showTimeSignaturePicker, titleVisibility: .visible) {
            ForEach(TimeSignature.allSignatures) { signature in
                Button(signature.description + " - " + signature.name) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        metronome.setTimeSignature(signature)
                    }
                }
            }
            Button("Cancelar", role: .cancel) {}
        }
    }

    var beatIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<metronome.timeSignature.beats, id: \.self) { beat in
                beatDot(for: beat)
            }
        }
        .padding(.vertical, 8)
        .animation(.easeInOut(duration: 0.15), value: metronome.currentBeat)
    }

    func beatDot(for beat: Int) -> some View {
        let isActive = beat == metronome.currentBeat && metronome.isPlaying

        return Circle()
            .fill(isActive ? theme.circleStroke : theme.circleStroke.opacity(0.3))
            .frame(width: 12, height: 12)
            .overlay(
                Circle()
                    .stroke(theme.circleStroke.opacity(0.5), lineWidth: 1)
            )
    }

    var themeButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                let allThemes = AppTheme.allCases
                if let currentIndex = allThemes.firstIndex(of: currentTheme) {
                    let nextIndex = (currentIndex + 1) % allThemes.count
                    currentTheme = allThemes[nextIndex]
                }
            }
        } label: {
            Image(systemName: "circle.lefthalf.filled")
                .font(.system(size: 24, weight: .regular))
                .foregroundColor(theme.buttonIcon)
                .padding(12)
                .background(
                    Circle()
                        .fill(theme.buttonFill.opacity(0.8))
                )
        }
    }

    var bpmIndicator: some View {
        ZStack {
            // Círculo de fundo
            Circle()
                .fill(theme.circleFill)
                .frame(width: 280, height: 280)

            // Círculo interno com animação de flash
            Circle()
                .stroke(
                    beatFlash && metronome.isPlaying
                        ? theme.circleStroke
                        : theme.circleStroke.opacity(0.3),
                    lineWidth: 2
                )
                .frame(width: 260, height: 260)
                .animation(.easeOut(duration: 0.1), value: beatFlash)

            VStack(spacing: 8) {
                Text("\(metronome.bpm)")
                    .font(.system(size: 80, weight: .bold, design: .rounded))
                    .foregroundColor(theme.text)
                    .contentTransition(.numericText())

                Text("BPM")
                    .font(.system(size: 24, weight: .light, design: .rounded))
                    .foregroundColor(theme.text.opacity(0.7))
            }
        }
        .drawingGroup() // Otimização de renderização
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
            .foregroundColor(theme.label.opacity(0.6))
    }

    var playPauseButton: some View {
        Button {
            metronome.togglePlayback()
            if metronome.isPlaying {
                triggerPulse()
            }
        } label: {
            ZStack {
                Circle()
                    .fill(theme.buttonFill)
                    .frame(width: 90, height: 90)

                Image(systemName: metronome.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 35, weight: .semibold))
                    .foregroundColor(theme.buttonIcon)
                    .contentTransition(.symbolEffect)
            }
        }
    }

    func controlButton(icon: String, action: @escaping () -> Void, isDisabled: Bool) -> some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(theme.buttonFill)
                    .frame(width: 70, height: 70)

                Image(systemName: icon)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundColor(theme.buttonIcon)
            }
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.4 : 1.0)
    }

    func smallControlButton(label: String, action: @escaping () -> Void, isDisabled: Bool) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(theme.buttonIcon)
                .frame(width: 80, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(theme.buttonFill)
                )
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.4 : 1.0)
    }
}

// MARK: - Animation Helpers
private extension MetronomeView {
    func triggerPulse() {
        pulseAnimation.toggle()
        triggerBeatFlash()
    }

    func triggerBeatFlash() {
        beatFlash = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            beatFlash = false
        }
    }

    func startPulseAnimation() {
        let interval = 60.0 / Double(metronome.bpm)
        animationTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            triggerPulse()
        }
    }

    func stopPulseAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }

    func restartPulseAnimation() {
        stopPulseAnimation()
        startPulseAnimation()
    }
}

#Preview {
    MetronomeView()
}
