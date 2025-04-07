//
//  CommandExecutor + Extension.swift
//  RaifMagicCore
//
//  Created by USOV Vasily on 18.02.2025.
//

import CommandExecutor

extension Logger: CommandExecutor.Logger {
    nonisolated public func log(commandExecutorServiceMessage message: String) {
        Task {
            await log(.debug, message: "[CommandExecutor] \(message)")
        }
    }
}
