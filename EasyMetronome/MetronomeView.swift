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
        GeometryReader { geometry in
            let availableHeight = geometry.size.height
                - geometry.safeAreaInsets.top
                - geometry.safeAreaInsets.bottom
                - 60  // header height estimate
                - 44  // time signature selector
                - 24  // beat indicator
                - 90  // primary controls
                - 44  // secondary controls
                - 100 // paddings total

            ZStack {
                theme.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    headerView
                        .padding(.top, geometry.safeAreaInsets.top + 10)
                        .padding(.bottom, 15)

                    timeSignatureSelector
                        .padding(.bottom, 15)

                    bpmIndicator(availableHeight: availableHeight, screenSize: geometry.size)
                        .padding(.bottom, 15)

                    beatIndicator
                        .padding(.bottom, 15)

                    primaryControls
                        .padding(.bottom, 15)

                    secondaryControls
                        .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
                }
                .padding(.horizontal, 20)
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

    var headerView: some View {
        ZStack {
            // Título centralizado
            Text("EasyMetronome")
                .font(.system(size: 28, weight: .light, design: .rounded))
                .foregroundColor(theme.title)
                .minimumScaleFactor(0.5)
                .lineLimit(1)

            // Botão de tema à direita
            HStack {
                Spacer()
                themeButton
            }
        }
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
        .confirmationDialog("Select Time Signature", isPresented: $showTimeSignaturePicker, titleVisibility: .visible) {
            ForEach(TimeSignature.allSignatures) { signature in
                Button(signature.description + " - " + signature.name) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        metronome.setTimeSignature(signature)
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
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

    func bpmIndicator(availableHeight: CGFloat, screenSize: CGSize) -> some View {
        // Usa a altura disponível ou largura, o que for menor
        let maxSize = min(availableHeight, screenSize.width - 40)
        let circleSize = max(maxSize * 0.85, 180) // Mínimo de 180pt
        let fontSize = circleSize * 0.28
        let bpmLabelSize = circleSize * 0.085
        let rangeLabelSize = circleSize * 0.042

        return ZStack {
            // Círculo de fundo
            Circle()
                .fill(theme.circleFill)
                .frame(width: circleSize, height: circleSize)

            // Círculo interno com animação de flash
            Circle()
                .stroke(
                    beatFlash && metronome.isPlaying
                        ? theme.circleStroke
                        : theme.circleStroke.opacity(0.3),
                    lineWidth: 2
                )
                .frame(width: circleSize * 0.93, height: circleSize * 0.93)
                .animation(.easeOut(duration: 0.1), value: beatFlash)

            VStack(spacing: 4) {
                Text("\(metronome.bpm)")
                    .font(.system(size: fontSize, weight: .bold, design: .rounded))
                    .foregroundColor(theme.text)
                    .contentTransition(.numericText())

                Text("BPM")
                    .font(.system(size: bpmLabelSize, weight: .light, design: .rounded))
                    .foregroundColor(theme.text.opacity(0.7))

                Text("\(metronome.minBPM) - \(metronome.maxBPM) BPM")
                    .font(.system(size: rangeLabelSize, weight: .regular, design: .rounded))
                    .foregroundColor(theme.label.opacity(0.5))
                    .padding(.top, 4)
            }
        }
        .drawingGroup()
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
