//
//  AppError.swift
//  RaifMagic
//
//  Created by USOV Vasily on 05.06.2024.
//

import Foundation

// MARK: - MagicError

public struct MagicError: LocalizedError {
    public let error: Error?
    public let errorDescription: String?
    
    public init(error: Error? = nil, errorDescription: String? = nil) {
        self.error = error
        self.errorDescription = errorDescription
    }
}

