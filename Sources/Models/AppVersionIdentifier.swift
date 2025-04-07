//
//  File.swift
//  
//
//  Created by USOV Vasily on 16.09.2024.
//

/// The object describes the version of the RaifMagic application
public protocol AppVersionDescribable {
    var major: Int { get }
    var minor: Int { get }
    var patch: Int { get }
    var isBeta: Bool { get }
    func isEqualVersion(_ version: AppVersionDescribable) -> Bool
}

extension AppVersionDescribable {
    public func isEqualVersion(_ version: AppVersionDescribable) -> Bool {
        self.major == version.major && self.minor == version.minor && self.patch == version.patch && self.isBeta == version.isBeta
    }
}

public struct AppVersionIdentifier: Sendable, Identifiable, Equatable {
    public var id: Int {
        asString.hashValue
    }
    public let major: Int
    public let minor: Int
    public let patch: Int
    public let isBeta: Bool
    
    public init(major: Int, minor: Int, patch: Int, isBeta: Bool) {
        self.major = major
        self.minor = minor
        self.patch = patch
        self.isBeta = isBeta
    }
    
    public var asString: String {
        "\(major).\(minor).\(patch)\(isBeta ? "beta" : "")"
    }
    
    public func isMajorHigher(than other: AppVersionIdentifier) -> Bool {
        major > other.major
    }
    
    public func isMinorHigher(than other: AppVersionIdentifier) -> Bool {
        major == other.major && minor > other.minor
    }
    
    public func isPatchHigher(than other: AppVersionIdentifier) -> Bool {
        major == other.major && minor == other.minor && patch > other.patch
    }
    
    public func isVersionHigher(than other: AppVersionIdentifier) -> Bool {
        isMajorHigher(than: other) || isMinorHigher(than: other) || isPatchHigher(than: other)
    }
}

extension AppVersionIdentifier: AppVersionDescribable {}
