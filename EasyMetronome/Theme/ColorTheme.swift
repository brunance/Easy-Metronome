//
//  ColorTheme.swift
//  EasyMetronome
//
//  Created by Bruno França do Prado on 05/10/25.
//

import SwiftUI

// MARK: - Theme System
enum AppTheme: String, CaseIterable {
    case rose = "Rose"
    case light = "Light"
    case dark = "Dark"

    var colors: ThemeColors {
        switch self {
        case .rose:
            return ThemeColors(
                background: Color("RoseBackground"),
                title: Color("RoseTitle"),
                circleFill: Color("RoseCircleFill"),
                circleStroke: Color("RoseCircleStroke"),
                text: Color("RoseText"),
                buttonFill: Color("RoseButtonFill"),
                buttonIcon: Color("RoseButtonIcon"),
                label: Color("RoseLabel")
            )
        case .light:
            return ThemeColors(
                background: Color("LightBackground"),
                title: Color("LightTitle"),
                circleFill: Color("LightCircleFill"),
                circleStroke: Color("LightCircleStroke"),
                text: Color("LightText"),
                buttonFill: Color("LightButtonFill"),
                buttonIcon: Color("LightButtonIcon"),
                label: Color("LightLabel")
            )
        case .dark:
            return ThemeColors(
                background: Color("DarkBackground"),
                title: Color("DarkTitle"),
                circleFill: Color("DarkCircleFill"),
                circleStroke: Color("DarkCircleStroke"),
                text: Color("DarkText"),
                buttonFill: Color("DarkButtonFill"),
                buttonIcon: Color("DarkButtonIcon"),
                label: Color("DarkLabel")
            )
        }
    }
}

// MARK: - Theme Colors Structure
struct ThemeColors {
    let background: Color
    let title: Color
    let circleFill: Color
    let circleStroke: Color
    let text: Color
    let buttonFill: Color
    let buttonIcon: Color
    let label: Color
}
