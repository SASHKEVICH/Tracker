//
//  Device.swift
//  Tracker
//
//  Created by Александр Бекренев on 05.04.2023.
//

import UIKit

enum Device {
    case iphoneSE
    case iphone8
    case iphone8plus
    case iphone11pro
    case iphone11proMax
    case iphoneXr
    
    static var type: Device {
        switch UIScreen.main.nativeBounds.height {
        case 1136:
            return .iphoneSE
        case 1334:
            return .iphone8
        case 1920, 2208:
            return .iphone8plus
        case 2436:
            return .iphone11pro
        case 2688:
            return .iphone11proMax
        case 1792:
            return .iphoneXr
        default:
            return .iphone11pro
        }
    }
}
