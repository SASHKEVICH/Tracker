//
//  Device.swift
//  Tracker
//
//  Created by Александр Бекренев on 05.04.2023.
//

import UIKit

enum Device {
    case iphoneSE
    case iphone7
    case iphone7plus
    case iphone8
    case iphone8plus
    case iphoneX
    case iphoneXGlobal
    case iphoneXS
    case iphoneXSMax
    case iphoneXSMaxGlobal
    case iphoneXr
    case iphone11
    case iphone11pro
    case iphone11proMax
    case iphoneSE2
    case iphone12Mini
    case iphone12
    case iphone12pro
    case iphone12proMax
    case iphone13Mini
    case iphone13
    case iphone13pro
    case iphone13proMax
    case iphoneSE3
    case iphone14Plus
    case iphone14
    case iphone14pro
    case iphone14proMax

    static var model: Device {
        guard let deviceCode = self.getDeviceCode() else {
            assertionFailure("Unknown device code")
            return .iphoneX
        }
        return devices[deviceCode] ?? .iphoneX
    }
}

private extension Device {
    static let devices: [String: Device] = [
        "iPhone8,4": .iphoneSE,
        "iPhone9,1": .iphone7,
        "iPhone9,2": .iphone7plus,
        "iPhone9,3": .iphone7,
        "iPhone9,4": .iphone7plus,
        "iPhone10,1": .iphone8,
        "iPhone10,2": .iphone8plus,
        "iPhone10,3": .iphoneXGlobal,
        "iPhone10,4": .iphone8,
        "iPhone10,5": .iphone8plus,
        "iPhone10,6": .iphoneX,
        "iPhone11,2": .iphoneXS,
        "iPhone11,4": .iphoneXSMax,
        "iPhone11,6": .iphoneXSMaxGlobal,
        "iPhone11,8": .iphoneXr,
        "iPhone12,1": .iphone11,
        "iPhone12,3": .iphone11pro,
        "iPhone12,5": .iphone11proMax,
        "iPhone12,8": .iphoneSE2,
        "iPhone13,1": .iphone12Mini,
        "iPhone13,2": .iphone12,
        "iPhone13,3": .iphone12pro,
        "iPhone13,4": .iphone12proMax,
        "iPhone14,2": .iphone13pro,
        "iPhone14,3": .iphone13proMax,
        "iPhone14,4": .iphone13Mini,
        "iPhone14,5": .iphone13,
        "iPhone14,6": .iphoneSE3,
        "iPhone14,7": .iphone14,
        "iPhone14,8": .iphone14Plus,
        "iPhone15,2": .iphone14pro,
        "iPhone15,3": .iphone14proMax,
    ]

    static func getDeviceCode() -> String? {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String(validatingUTF8: ptr)
            }
        }
        return modelCode
    }
}
