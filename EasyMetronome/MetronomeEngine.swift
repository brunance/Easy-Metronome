//
//  MetronomeEngine.swift
//  EasyMetronome
//
//  Created by Bruno França do Prado on 04/10/25.
//

import Foundation
import AVFoundation
import Combine

extension UInt16 {
    var littleEndianData: Data {
        var value = self.littleEndian
        return Data(bytes: &value, count: MemoryLayout<UInt16>.size)
    }
}

extension UInt32 {
    var littleEndianData: Data {
        var value = self.littleEndian
        return Data(bytes: &value, count: MemoryLayout<UInt32>.size)
    }
}

extension Int16 {
    var littleEndianData: Data {
        var value = self.littleEndian
        return Data(bytes: &value, count: MemoryLayout<Int16>.size)
    }
}

// MARK: - MetronomeEngine
/// Gerencia o metrônomo: BPM, timer e reprodução de áudio
class MetronomeEngine: ObservableObject {
    
    // MARK: - Published Properties
    @Published var bpm: Int = 120
    @Published var isPlaying: Bool = false
    
    // MARK: - Constants
    let minBPM = 40
    let maxBPM = 240
    private let defaultBPM = 120
    
    // MARK: - Private Properties
    private var timer: Timer?
    private var audioPlayer: AVAudioPlayer?
    
    // MARK: - Initialization
    init() {
        setupAudioSession()
        setupAudio()
    }
    
    // MARK: - Audio Setup
    private func setupAudioSession() {
        #if os(iOS)
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Erro ao configurar sessão de áudio: \(error)")
        }
        #endif
    }
    
    private func setupAudio() {
        // Gera um som de clique sintetizado
        let sampleRate = 44100.0
        let duration = 0.05
        let frequency = 1000.0
        
        let frameCount = Int(sampleRate * duration)
        
        // Cria dados de áudio em formato PCM 16-bit
        var audioData = [Int16]()
        
        for i in 0..<frameCount {
            let time = Double(i) / sampleRate
            let amplitude = exp(-time * 50) // Envelope de decaimento
            let twoPi = 2.0 * Double.pi
            let phase = twoPi * frequency * time
            let sineWave = sin(phase)
            let sample = Int16(amplitude * sineWave * Double(Int16.max))
            audioData.append(sample)
        }
        
        // Salva em arquivo WAV temporário
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("metronome_click.wav")
        
        do {
            // Remove arquivo anterior se existir
            try? FileManager.default.removeItem(at: tempURL)
            
            // Cria arquivo WAV manualmente
            let wavData = createWAVData(from: audioData, sampleRate: Int(sampleRate))
            try wavData.write(to: tempURL)
            
            audioPlayer = try AVAudioPlayer(contentsOf: tempURL)
            audioPlayer?.volume = 1.0
            audioPlayer?.numberOfLoops = 0
            audioPlayer?.prepareToPlay()
            print("Áudio configurado com sucesso em: \(tempURL)")
        } catch {
            print("Erro ao criar som: \(error)")
        }
    }
    
    private func createWAVData(from samples: [Int16], sampleRate: Int) -> Data {
        var data = Data()
        
        let numChannels: UInt16 = 1
        let bitsPerSample: UInt16 = 16
        let byteRate = UInt32(sampleRate) * UInt32(numChannels) * UInt32(bitsPerSample / 8)
        let blockAlign = numChannels * (bitsPerSample / 8)
        let dataSize = UInt32(samples.count * 2)
        
        // RIFF header
        data.append("RIFF".data(using: .ascii)!)
        data.append(UInt32(36 + dataSize).littleEndianData)
        data.append("WAVE".data(using: .ascii)!)
        
        // fmt chunk
        data.append("fmt ".data(using: .ascii)!)
        data.append(UInt32(16).littleEndianData) // chunk size
        data.append(UInt16(1).littleEndianData) // audio format (PCM)
        data.append(numChannels.littleEndianData)
        data.append(UInt32(sampleRate).littleEndianData)
        data.append(byteRate.littleEndianData)
        data.append(blockAlign.littleEndianData)
        data.append(bitsPerSample.littleEndianData)
        
        // data chunk
        data.append("data".data(using: .ascii)!)
        data.append(dataSize.littleEndianData)
        
        for sample in samples {
            data.append(sample.littleEndianData)
        }
        
        return data
    }
    
    // MARK: - Playback Control
    func start() {
        guard !isPlaying else { return }
        isPlaying = true
        playClick()
        scheduleTimer()
    }
    
    func stop() {
        isPlaying = false
        timer?.invalidate()
        timer = nil
    }
    
    func togglePlayback() {
        if isPlaying {
            stop()
        } else {
            start()
        }
    }
    
    // MARK: - BPM Control
    func increaseBPM(by amount: Int = 1) {
        adjustBPM(by: amount)
    }
    
    func decreaseBPM(by amount: Int = 1) {
        adjustBPM(by: -amount)
    }
    
    func setBPM(_ newBPM: Int) {
        bpm = min(max(newBPM, minBPM), maxBPM)
        if isPlaying {
            rescheduleTimer()
        }
    }
    
    private func adjustBPM(by amount: Int) {
        let newBPM = bpm + amount
        setBPM(newBPM)
    }
    
    // MARK: - Timer Management
    private func scheduleTimer() {
        let interval = 60.0 / Double(bpm)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.playClick()
        }
    }
    
    private func rescheduleTimer() {
        timer?.invalidate()
        scheduleTimer()
    }
    
    // MARK: - Audio Playback
    private func playClick() {
        guard let player = audioPlayer else {
            print("Audio player não está disponível")
            return
        }
        player.currentTime = 0
        let success = player.play()
        if !success {
            print("Falha ao tocar o som")
        }
    }
}
