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

    // Compassos comuns
    static let common = TimeSignature(beats: 4, noteValue: 4, name: "Comum")
    static let waltz = TimeSignature(beats: 3, noteValue: 4, name: "Valsa")
    static let march = TimeSignature(beats: 2, noteValue: 4, name: "Marcha")
    static let compound = TimeSignature(beats: 6, noteValue: 8, name: "Composto")
    static let fiveFour = TimeSignature(beats: 5, noteValue: 4, name: "Cinco por Quatro")
    static let sevenEight = TimeSignature(beats: 7, noteValue: 8, name: "Sete por Oito")

    static let allSignatures: [TimeSignature] = [
        .common,
        .waltz,
        .march,
        .compound,
        .fiveFour,
        .sevenEight
    ]
}
