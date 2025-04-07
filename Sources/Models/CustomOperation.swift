//
//  FastCommand.swift
//  RaifMagic
//
//  Created by USOV Vasily on 25.06.2024.
//

import Foundation

/// Section with custom elements (operations, links)
///
/// Used on the screen with Operations, in the sidebars of various screens
public struct CustomActionSection: Identifiable {
    public var id: Int {
        title.hashValue
    }
    public let title: String
    public let items: [any CustomAction]
    
    public init(title: String, operations: [any CustomAction]) {
        self.title = title
        self.items = operations
    }
}

/// Interface for defining a custom action
public protocol CustomAction: Identifiable {
    var id: Int { get }
    var title: String { get }
}

public struct CustomWebLink: CustomAction, Hashable, Sendable {
    public var id: Int {
        title.hashValue
    }
    public let title: String
    public let description: String?
    public let confirmationDescription: String?
    public let url: URL
    
    public init(title: String, description: String? = nil, confirmationDescription: String? = nil, url: URL) {
        self.title = title
        self.description = description
        self.confirmationDescription = confirmationDescription
        self.url = url
    }
}

/// Custom operation
public struct CustomOperation: CustomAction, Hashable, Sendable {
    public var id: Int {
        title.hashValue
    }
    public let title: String
    public let description: String?
    public let icon: String
    public let confirmationDescription: String?
    public let closure: @Sendable () async -> Void
    
    public init(title: String, description: String? = nil, icon: String = "play", confirmationDescription: String? = nil, closure: @Sendable @escaping () async -> Void) {
        self.title = title
        self.description = description
        self.icon = icon
        self.confirmationDescription = confirmationDescription
        self.closure = closure
    }
    
    public static func == (lhs: CustomOperation, rhs: CustomOperation) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
    }
}
