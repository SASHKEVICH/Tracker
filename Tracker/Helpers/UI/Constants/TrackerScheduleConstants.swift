//
//  TrackerScheduleConstants.swift
//  Tracker
//
//  Created by Александр Бекренев on 18.04.2023.
//

import Foundation

struct TrackerScheduleConstants {
    let bottomConstantConstraint: CGFloat
    
    static var configuration: TrackerScheduleConstants {
        let currentDeviceType = Device.model
        switch currentDeviceType {
        case .iphoneSE, .iphoneSE2, .iphoneSE3, .iphone7, .iphone7plus, .iphone8, .iphone8plus:
            return iPhoneSEConfiguration
        default:
            return iPhoneXConfiguration
        }
    }
}

private extension TrackerScheduleConstants {
	static var iPhoneXConfiguration: TrackerScheduleConstants {
		TrackerScheduleConstants(bottomConstantConstraint: 16)
	}

	static var iPhoneSEConfiguration: TrackerScheduleConstants {
		TrackerScheduleConstants(bottomConstantConstraint: 24)
	}
}
