import UIKit

final class MainTabBarCoordinator: Coordinator {

    enum Screen {
        case main
        case statistics
    }

    // MARK: - Private Properties

    private let tabBarController: UITabBarController
    private let screenFactory: StatisticsViewFactory & MainViewFactory

    // MARK: - Init

    init(
        tabBarController: UITabBarController,
        screenFactory: StatisticsViewFactory & MainViewFactory
    ) {
        self.tabBarController = tabBarController
        self.screenFactory = screenFactory

        self.setupTabBar()
    }

    func start() {
    }
}

private extension MainTabBarCoordinator {

    func setupTabBar() {
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = .Dynamic.whiteDay
        self.tabBarController.tabBar.standardAppearance = appearance
    }
}
