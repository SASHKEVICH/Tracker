//
//  OnboardingConstants.swift
//  Tracker
//
//  Created by Александр Бекренев on 16.06.2023.
//

import Foundation

struct OnboardingConstants {
    let topConstantConstraint: CGFloat
    let bottomConstantConstraint: CGFloat

    static var configuration: OnboardingConstants {
        let currentDeviceType = Device.model
        switch currentDeviceType {
        case .iphoneSE, .iphoneSE2, .iphoneSE3, .iphone7, .iphone7plus, .iphone8, .iphone8plus:
            return iPhoneSEConfiguration
        default:
            return iPhoneXConfiguration
        }
    }
}

private extension OnboardingConstants {
    static var iPhoneXConfiguration: OnboardingConstants {
        OnboardingConstants(topConstantConstraint: 432, bottomConstantConstraint: 254)
    }

    static var iPhoneSEConfiguration: OnboardingConstants {
        OnboardingConstants(topConstantConstraint: 254, bottomConstantConstraint: 200)
    }
}
