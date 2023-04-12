//
//  Array+SafeSubscript.swift
//  Tracker
//
//  Created by Александр Бекренев on 12.04.2023.
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }

        return self[index]
    }
}
