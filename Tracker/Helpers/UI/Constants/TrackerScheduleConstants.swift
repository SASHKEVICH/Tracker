//
//  TrackerScheduleConstants.swift
//  Tracker
//
//  Created by Александр Бекренев on 18.04.2023.
//

import Foundation

struct TrackerScheduleConstants {
    let bottomConstantConstraint: CGFloat
    
    private static var iPhoneXConfiguration: TrackerScheduleConstants {
        return TrackerScheduleConstants(bottomConstantConstraint: 16)
    }
        
    private static var iPhoneSEConfiguration: TrackerScheduleConstants {
        return TrackerScheduleConstants(bottomConstantConstraint: 24)
    }
    
    static var configuration: TrackerScheduleConstants {
        let currentDeviceType = Device.type
        switch currentDeviceType {
        case .iphoneSE:
            return iPhoneSEConfiguration
        default:
            return iPhoneXConfiguration
        }
    }
}
