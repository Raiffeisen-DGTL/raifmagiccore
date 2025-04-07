//
//  DebugResolver.swift
//  RaifMagic
//
//  Created by USOV Vasily on 16.12.2024.
//

// TODO: - This has no place here, of course. Logically, each target has its own
public func resolve(debug: Bool, release: Bool) -> Bool {
#if DEBUG
    return debug
#else
    return release
#endif
}
