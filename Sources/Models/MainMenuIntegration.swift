//
//  Untitled.swift
//  RaifMagicCore
//
//  Created by USOV Vasily on 17.03.2025.
//

import SwiftUI

/// Structure for integrating a screen into the main menu of an application
public struct MainMenuIntegration: Identifiable {
    public var id: String {
        screen.id
    }
    public var title: String
    public var systemImage: String
    public var sortIndex: Int
    public var section: Section
    public var icon: Icon? = nil
    public var screen: any MagicScreen
    public var backgroundGradientColors: [Color]
    
    public init(title: String,
                systemImage: String,
                backgroundGradientColors: [Color] = [Color.cyan.opacity(0.7), Color.cyan],
                sortIndex: Int,
                section: Section,
                screen: any MagicScreen) {
        self.title = title
        self.systemImage = systemImage
        self.backgroundGradientColors = backgroundGradientColors
        self.sortIndex = sortIndex
        self.section = section
        self.screen = screen
    }
    
    public enum Section {
        case top
        case project
        case environment
        case other
    }
    
    public enum Icon {
        case progress
        case warning
        case error
    }
}
