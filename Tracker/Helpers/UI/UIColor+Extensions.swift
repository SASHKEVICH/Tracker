//
//  UIColor+Extensions.swift
//  Tracker
//
//  Created by Александр Бекренев on 31.03.2023.
//

import UIKit

extension UIColor {
	struct Dynamic {
		static let backgroundDay = UIColor.color(named: "TrackerBackgroundDay")
		static let whiteDay = UIColor.color(named: "TrackerWhiteDay")
		static let blackDay = UIColor.color(named: "TrackerBlackDay")
	}

	struct Static {
		static let blue = UIColor.color(named: "TrackerBlue")
		static let gray = UIColor.color(named: "TrackerGray")
		static let lightGray = UIColor.color(named: "TrackerLightGray")
		static let red = UIColor.color(named: "TrackerRed")
		static let switchBackground = UIColor.color(named: "TrackerSwitchBackgroundColor")
	}

	struct Selection {
		static let color1  = UIColor.color(named: "TrackerColorSelection1")
		static let color2  = UIColor.color(named: "TrackerColorSelection2")
		static let color3  = UIColor.color(named: "TrackerColorSelection3")
		static let color4  = UIColor.color(named: "TrackerColorSelection4")
		static let color5  = UIColor.color(named: "TrackerColorSelection5")
		static let color6  = UIColor.color(named: "TrackerColorSelection6")
		static let color7  = UIColor.color(named: "TrackerColorSelection7")
		static let color8  = UIColor.color(named: "TrackerColorSelection8")
		static let color9  = UIColor.color(named: "TrackerColorSelection9")
		static let color10 = UIColor.color(named: "TrackerColorSelection10")
		static let color11 = UIColor.color(named: "TrackerColorSelection11")
		static let color12 = UIColor.color(named: "TrackerColorSelection12")
		static let color13 = UIColor.color(named: "TrackerColorSelection13")
		static let color14 = UIColor.color(named: "TrackerColorSelection14")
		static let color15 = UIColor.color(named: "TrackerColorSelection15")
		static let color16 = UIColor.color(named: "TrackerColorSelection16")
		static let color17 = UIColor.color(named: "TrackerColorSelection17")
		static let color18 = UIColor.color(named: "TrackerColorSelection18")
	}
}

extension UIColor {
	static func color(named: String) -> UIColor {
		guard let color = UIColor(named: named) else { fatalError("Cannot load color \(named) from assets") }
		return color
	}
}
