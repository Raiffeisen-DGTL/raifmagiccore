//
//  String + Extension.swift
//  RaifMagic
//
//  Created by USOV Vasily on 06.06.2024.
//

import Foundation
import CommandExecutor

extension String {
    var basicAuth: String? {
        let options: NSData.Base64EncodingOptions = .init(rawValue: 0)
        let basicTokenBase64Encoded = data(using: .utf8)?.base64EncodedString(options: options)
        return basicTokenBase64Encoded.flatMap { String(format: "Basic %@", $0) }
    }
}

public extension String {
    var asCommand: Command {
        Command(self)
    }
}
