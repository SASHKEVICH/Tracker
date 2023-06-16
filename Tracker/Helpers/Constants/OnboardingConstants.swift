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
	
	private static var iPhoneXConfiguration: OnboardingConstants {
		OnboardingConstants(topConstantConstraint: 432, bottomConstantConstraint: 304)
	}
		
	private static var iPhoneSEConfiguration: OnboardingConstants {
		OnboardingConstants(topConstantConstraint: 254, bottomConstantConstraint: 200)
	}
	
	static var configuration: OnboardingConstants {
		let currentDeviceType = Device.type
		switch currentDeviceType {
		case .iphoneSE:
			return iPhoneSEConfiguration
		default:
			return iPhoneXConfiguration
		}
	}
}
