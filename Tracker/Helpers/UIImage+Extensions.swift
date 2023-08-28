//
//  UIImage+Extensions.swift
//  Tracker
//
//  Created by Александр Бекренев on 27.05.2023.
//

import UIKit

extension UIImage {
    enum Onboarding {
        static var first: UIImage? { R.image.onboarding_1() }
        static var second: UIImage? { R.image.onboarding_2() }
    }

    enum Categories {
        static var selected: UIImage? { R.image.categorySelectedIcon() }
    }

    enum MainScreen {
        static var addTracker: UIImage? { R.image.addTrackerIcon() }
        static var pinned: UIImage? { UIImage(systemName: "pin.fill",
                                              withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 12))) }
    }

    enum Launch {
        static var logo: UIImage? { R.image.practicumLogo() }
    }

    enum Placeholder {
        static var emptyForDay: UIImage? { R.image.trackersPlaceholderViewEmptyForDay() }
        static var emptySearch: UIImage? { R.image.trackersPlaceholderViewEmptySearch() }
        static var emptyStatistics: UIImage? { R.image.trackersPlaceholderViewEmptyStatistics() }
    }

    enum TabBar {
        static var trackers: UIImage? { R.image.trackersTabBarItem() }
        static var statistics: UIImage? { R.image.statisticsTabBarItem() }
    }

    enum CompleteTrackerButton {
        static var completed: UIImage? { UIImage(systemName: "checkmark") }
        static var increase: UIImage? { UIImage(systemName: "plus") }
        static var decrease: UIImage? { UIImage(systemName: "minus") }
    }
}
