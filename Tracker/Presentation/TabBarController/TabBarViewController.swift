//
//  TabBarViewController.swift
//  Tracker
//
//  Created by Александр Бекренев on 31.03.2023.
//

import UIKit

final class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trackersViewController = setupTrackersViewController()
        let statisticsViewController = setupStatisticsViewController()
        viewControllers = [trackersViewController, statisticsViewController]
        
        setupTabBar()
    }
    
    private func setupTabBar() {
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = .trackerBackgroundColor
        tabBar.standardAppearance = appearance
    }
}

// MARK: Setup view controllers
private extension TabBarViewController {
    func setupTrackersViewController() -> TrackersViewController {
        let trackersViewController = TrackersViewController()
        trackersViewController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "TrackersTabBarItem"),
            selectedImage: nil)
        return trackersViewController
    }
    
    func setupStatisticsViewController() -> StatisticsViewController {
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "StatisticsTabBarItem"),
            selectedImage: nil)
        return statisticsViewController
    }
}
