//
//  UIImage+Extensions.swift
//  Tracker
//
//  Created by Александр Бекренев on 27.05.2023.
//

import UIKit

extension UIImage {
	struct Onboarding {
		static let first = UIImage.image(named: "Onboarding_1")
		static let second = UIImage.image(named: "Onboarding_2")
	}

	struct Categories {
		static let selected = UIImage.image(named: "CategorySelectedIcon")
	}

	struct MainScreen {
		static let addTracker = UIImage.image(named: "AddTrackerIcon")
	}

	struct Launch {
		static let logo = UIImage.image(named: "PracticumLogo")
	}

	struct Placeholder {
		static let emptyForDay = UIImage.image(named: "TrackersPlaceholderViewEmptyForDay")
		static let emptySearch = UIImage.image(named: "TrackersPlaceholderViewEmptySearch")
	}

	struct TabBar {
		static let trackers = UIImage.image(named: "TrackersTabBarItem")
		static let statistics = UIImage.image(named: "StatisticsTabBarItem")
	}
}

extension UIImage {
	static func image(named: String) -> UIImage {
		guard let image = UIImage(named: named) else { fatalError("Cannot load image for name: \(named)") }
		return image
	}
}
