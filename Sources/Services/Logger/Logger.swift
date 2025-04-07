//
//  Logger.swift
//  RaifMagic
//
//  Created by USOV Vasily on 27.05.2024.
//

import Foundation
import OSLog

// TODO: Improvement of the logging system
// - Add the ability to change the logging level directly online

// TODO: Maybe actor? if you give the ability to configure levels in runtime + privacyHandler is currently being configured
public final class Logger: @unchecked Sendable {
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy-MM-dd"
        return dateFormatter
    }()
    private var currentLogFileName: String {
        dateFormatter.string(from: Date())
    }
    private var privacyHandler: ((String) async -> String)? = nil
    private let useLogIntoConsole: Bool
    private let useLogIntoOsLog: Bool
    private let useLogIntoFileWithDirectoryPath: String?
    private let logLevels: [LogLevel]
    
    public init(useLogIntoConsole: Bool, useLogIntoOsLog: Bool, useLogIntoFileWithDirectoryPath: String?, levels: [LogLevel]) {
        self.useLogIntoConsole = useLogIntoConsole
        self.useLogIntoOsLog = useLogIntoOsLog
        self.useLogIntoFileWithDirectoryPath = useLogIntoFileWithDirectoryPath
        self.logLevels = levels
    }
    
    public func enablePrivacyContentHidding(_ privacyHandler: @escaping (String) async -> String) {
        self.privacyHandler = privacyHandler
    }
    
    public func log(
        _ type: LogLevel,
        message: String,
        function: String = #function,
        file: String = #file,
        line: Int = #line,
        column: Int = #column
    ) async {
        let privacyHiddenMessage = if let privacyHandler {
            await privacyHandler(message)
        } else { message }
        
        if useLogIntoOsLog {
            os.Logger.application.log("\(privacyHiddenMessage, privacy: .public)")
        }
        if let useLogIntoFileWithDirectoryPath {
            writeToFile(filePath: useLogIntoFileWithDirectoryPath + "/" + currentLogFileName + ".log", message: privacyHiddenMessage)
        }
        if useLogIntoConsole {
            let resultMessage = """
        
        \(privacyHiddenMessage)
        DATE: \(Date())
        TYPE: \(type.rawValue)
        FUNCTION: \(function)
        FILE: \(file), LINE: \(line), COLUMN \(column)
        
        """
            
            print(resultMessage)
        }
    }
    
    // TODO: Write to the file not immediately, but once every few seconds, so as not to overload
    // Or on demand, for example, when closing/minimizing the application
    private func writeToFile(filePath: String, message: String) {
        if FileManager.default.fileExists(atPath: filePath) == false {
            FileManager.default.createFile(atPath: filePath, contents: nil)
        }
        let filePathURL = URL(filePath: filePath)
        try? message.data(using: .utf8)?.append(fileURL: filePathURL)
    }
}

// TODO: Remove extension as it is not obvious what it does. Do this within the writeToFile function
private extension Data {
     func append(fileURL: URL) throws {
         if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
             defer {
                 fileHandle.closeFile()
             }
             fileHandle.seekToEndOfFile()
             fileHandle.write(self)
         }
         else {
             try write(to: fileURL, options: .atomic)
         }
     }
 }

// MARK: - Subtypes

public enum LogLevel: String, Sendable {
    case debug = "⚠️ DEBUG"
    case warning = "‼️ WARNING"
}

extension os.Logger {
    static let application = Self(subsystem: "raifmagic", category: "application")
}
