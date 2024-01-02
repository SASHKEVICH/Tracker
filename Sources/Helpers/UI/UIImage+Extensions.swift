//
//  UIImage+Extensions.swift
//  Tracker
//
//  Created by Александр Бекренев on 27.05.2023.
//

import UIKit

extension UIImage {
    enum Onboarding {
        static let first = R.image.onboarding_1()
        static let second = R.image.onboarding_2()
    }

    enum Categories {
        static let selected = R.image.categorySelectedIcon()
    }

    enum MainScreen {
        static let addTracker = R.image.addTrackerIcon()
        static let pinned = UIImage(systemName: "pin.fill",
                                    withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 12)))
    }

    enum Launch {
        static let logo = R.image.practicumLogo()
    }

    enum Placeholder {
        static let emptyForDay = R.image.trackersPlaceholderViewEmptyForDay()
        static let emptySearch = R.image.trackersPlaceholderViewEmptySearch()
        static let emptyStatistics = R.image.trackersPlaceholderViewEmptyStatistics()
    }

    enum TabBar {
        static let trackers = R.image.trackersTabBarItem()
        static let statistics = R.image.statisticsTabBarItem()
    }

    enum CompleteTrackerButton {
        static let completed = UIImage(systemName: "checkmark")
        static let increase = UIImage(systemName: "plus")
        static let decrease = UIImage(systemName: "minus")
    }
}
