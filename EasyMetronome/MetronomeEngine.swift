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
/// Manages the metronome: BPM, timer and audio playback
class MetronomeEngine: ObservableObject {

    // MARK: - Published Properties
    @Published var bpm: Int = 120
    @Published var isPlaying: Bool = false
    @Published var timeSignature: TimeSignature = .common
    @Published var currentBeat: Int = 0

    // MARK: - Constants
    let minBPM = 40
    let maxBPM = 240
    private let defaultBPM = 120

    // MARK: - Private Properties
    private var timer: Timer?
    private var audioPlayerNormal: AVAudioPlayer?
    private var audioPlayerAccent: AVAudioPlayer?

    // MARK: - Initialization
    init() {
        setupAudioSession()
        setupAudio()
    }

    // MARK: - Audio Setup
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Error configuring audio session: \(error)")
        }
    }

    private func setupAudio() {
        // Create normal sound (regular click)
        audioPlayerNormal = createAudioPlayer(frequency: 1000.0, fileName: "metronome_click.wav")

        // Create accented sound (first beat)
        audioPlayerAccent = createAudioPlayer(frequency: 1200.0, fileName: "metronome_accent.wav")
    }

    private func getCacheDirectory() -> URL? {
        guard let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }

        // Create subdirectory for metronome sounds
        let metronomeCache = cacheDir.appendingPathComponent("MetronomeSounds", isDirectory: true)

        // Create directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: metronomeCache.path) {
            try? FileManager.default.createDirectory(at: metronomeCache, withIntermediateDirectories: true)
        }

        return metronomeCache
    }

    private func createAudioPlayer(frequency: Double, fileName: String) -> AVAudioPlayer? {
        guard let cacheDir = getCacheDirectory() else {
            print("Error accessing cache directory")
            return nil
        }

        let fileURL = cacheDir.appendingPathComponent(fileName)

        // Check if file already exists in cache
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            // Generate sound only if it doesn't exist
            let sampleRate = 44100.0
            let duration = 0.05

            let frameCount = Int(sampleRate * duration)
            var audioData = [Int16]()

            for integer in 0..<frameCount {
                let time = Double(integer) / sampleRate
                let amplitude = exp(-time * 50) // Decay envelope
                let twoPi = 2.0 * Double.pi
                let phase = twoPi * frequency * time
                let sineWave = sin(phase)
                let sample = Int16(amplitude * sineWave * Double(Int16.max))
                audioData.append(sample)
            }

            do {
                let wavData = createWAVData(from: audioData, sampleRate: Int(sampleRate))
                try wavData.write(to: fileURL)
                print("✅ Sound created and saved to cache: \(fileName)")
            } catch {
                print("Error saving sound to cache: \(error)")
                return nil
            }
        } else {
            print("♻️ Sound loaded from cache: \(fileName)")
        }

        // Load player from cached file
        do {
            let player = try AVAudioPlayer(contentsOf: fileURL)
            player.volume = 1.0
            player.numberOfLoops = 0
            player.prepareToPlay()
            return player
        } catch {
            print("Error creating audio player: \(error)")
            return nil
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
        currentBeat = 0
        playClick()
        scheduleTimer()
    }

    func stop() {
        isPlaying = false
        currentBeat = 0
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

    // MARK: - Time Signature Control
    func setTimeSignature(_ signature: TimeSignature) {
        // Avoid unnecessary processing if it's the same signature
        guard signature != timeSignature else { return }

        timeSignature = signature
        currentBeat = 0

        // Only reschedule if playing
        if isPlaying {
            DispatchQueue.main.async { [weak self] in
                self?.rescheduleTimer()
            }
        }
    }

    // MARK: - Cache Management
    /// Clears audio files from cache (useful for debug or to regenerate sounds)
    func clearAudioCache() {
        guard let cacheDir = getCacheDirectory() else { return }

        do {
            try FileManager.default.removeItem(at: cacheDir)
            print("🗑️ Audio cache cleared")
        } catch {
            print("Error clearing cache: \(error)")
        }
    }

    /// Returns cache size in bytes
    func getCacheSize() -> Int64 {
        guard let cacheDir = getCacheDirectory() else { return 0 }

        var totalSize: Int64 = 0

        if let enumerator = FileManager.default.enumerator(at: cacheDir, includingPropertiesForKeys: [.fileSizeKey]) {
            for case let fileURL as URL in enumerator {
                if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    totalSize += Int64(fileSize)
                }
            }
        }

        return totalSize
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
        // Determine if it's the first beat (accented) or not
        let isAccent = currentBeat == 0
        let player = isAccent ? audioPlayerAccent : audioPlayerNormal

        guard let player = player else {
            print("Audio player is not available")
            return
        }

        player.currentTime = 0
        let success = player.play()
        if !success {
            print("Failed to play sound")
        }

        // Advance to next beat
        currentBeat = (currentBeat + 1) % timeSignature.beats
    }
}
