//
//  TimeSignature.swift
//  EasyMetronome
//
//  Created by Bruno França do Prado on 05/10/25.
//

import Foundation

// MARK: - Time Signature
struct TimeSignature: Identifiable, Equatable {
    let id = UUID()
    let beats: Int
    let noteValue: Int
    let name: String

    var description: String {
        "\(beats)/\(noteValue)"
    }

    // Common time signatures
    static let common = TimeSignature(beats: 4, noteValue: 4, name: "Common")
    static let waltz = TimeSignature(beats: 3, noteValue: 4, name: "Waltz")
    static let march = TimeSignature(beats: 2, noteValue: 4, name: "March")
    static let compound = TimeSignature(beats: 6, noteValue: 8, name: "Compound")
    static let fiveFour = TimeSignature(beats: 5, noteValue: 4, name: "Five Four")
    static let sevenEight = TimeSignature(beats: 7, noteValue: 8, name: "Seven Eight")

    static let allSignatures: [TimeSignature] = [
        .common,
        .waltz,
        .march,
        .compound,
        .fiveFour,
        .sevenEight
    ]
}
