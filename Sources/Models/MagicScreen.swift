//
//  MagicScreen.swift
//  RaifMagicCore
//
//  Created by USOV Vasily on 17.03.2025.
//

import SwiftUI

/// Screen for embedding into the application interface
public protocol MagicScreen: Identifiable {
    var id: String { get }
    @MainActor
    func show(data: ScreenCommonData, arguments: Any?) -> AnyView
}

/// A structure that defines common auxiliary data for all opened data screens.
public struct ScreenCommonData: Sendable {
    public let projectPath: String
    
    public init(projectPath: String) {
        self.projectPath = projectPath
    }
}
