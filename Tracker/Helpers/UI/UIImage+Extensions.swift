//
//  UIImage+Extensions.swift
//  Tracker
//
//  Created by Александр Бекренев on 27.05.2023.
//

import UIKit

extension UIImage {
	struct Onboarding {
		static let first = R.image.onboarding_1()
		static let second = R.image.onboarding_2()
	}

	struct Categories {
		static let selected = R.image.categorySelectedIcon()
	}

	struct MainScreen {
		static let addTracker = R.image.addTrackerIcon()
		static let pinned = UIImage(systemName: "pin.fill",
									withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 12)))
	}

	struct Launch {
		static let logo = R.image.practicumLogo()
	}

	struct Placeholder {
		static let emptyForDay = R.image.trackersPlaceholderViewEmptyForDay()
		static let emptySearch = R.image.trackersPlaceholderViewEmptySearch()
		static let emptyStatistics = R.image.trackersPlaceholderViewEmptyStatistics()
	}

	struct TabBar {
		static let trackers = R.image.trackersTabBarItem()
		static let statistics = R.image.statisticsTabBarItem()
	}

	struct CompleteTrackerButton {
		static let completed = UIImage(systemName: "checkmark")
		static let increase = UIImage(systemName: "plus")
		static let decrease = UIImage(systemName: "minus")
	}
}
