//
//  Dictionary + Extension.swift
//
//
//  Created by ANPILOV Roman on 09.09.2024.
//

import Foundation

extension Dictionary where Value: Equatable {
    mutating func merge(with dictionary: Dictionary) {
        dictionary.forEach { updateValue($1, forKey: $0) }
    }
    
    func someKey(forValue val: Value) -> Key? {
        return first(where: { $1 == val })?.key
    }
}
