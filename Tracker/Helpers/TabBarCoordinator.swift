import UIKit

protocol TabBarCoordinatorProtocol: Coordinator {
    var tabBarController: UITabBarController { get set }
    var currentPage: TabBarPage? { get }
    func selectPage(_ page: TabBarPage)
    func setSelectedIndex(_ index: Int)
}

final class TabBarCoordinator: NSObject, TabBarCoordinatorProtocol {
    weak var finishDelegate: CoordinatorFinishDelegate?

    var tabBarController: UITabBarController
    var navigationController: UINavigationController

    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType { .tab }

    var currentPage: TabBarPage? { TabBarPage(index: self.tabBarController.selectedIndex) }

    private let serviceSetupper: ServiceSetupperProtocol

    init(_ navigationController: UINavigationController, serviceSetupper: ServiceSetupperProtocol) {
        self.navigationController = navigationController
        self.serviceSetupper = serviceSetupper
        self.tabBarController = UITabBarController()
    }

    func start() {
        let pages: [TabBarPage] = [.trackers, .statistics].sorted { $0.pageOrderNumber < $1.pageOrderNumber }
        let controllers: [UINavigationController] = pages.map { self.getTabController($0) }
        self.prepareTabBarController(withTabControllers: controllers)
    }

    func selectPage(_ page: TabBarPage) {
        self.tabBarController.selectedIndex = page.pageOrderNumber
    }

    func setSelectedIndex(_ index: Int) {
        guard let page = TabBarPage(index: index) else { return }
        self.tabBarController.selectedIndex = page.pageOrderNumber
    }
}

private extension TabBarCoordinator {
    func prepareTabBarController(withTabControllers tabControllers: [UIViewController]) {
        self.tabBarController.setViewControllers(tabControllers, animated: true)

        self.tabBarController.selectedIndex = TabBarPage.trackers.pageOrderNumber
        self.navigationController.viewControllers = [self.tabBarController]

        self.styleTabBar()
    }

    func getTabController(_ page: TabBarPage) -> UINavigationController {
        let navigationController = UINavigationController()
        navigationController.setNavigationBarHidden(false, animated: false)
        navigationController.navigationBar.prefersLargeTitles = true

        navigationController.tabBarItem = UITabBarItem(
            title: page.pageTitleValue,
            image: page.icon,
            tag: page.pageOrderNumber
        )

        switch page {
        case .trackers:
            let trackersVC = self.getTrackersViewController()
            navigationController.pushViewController(trackersVC, animated: true)
        case .statistics:
            let statisticsVC = self.getStatisticsViewController()
            navigationController.pushViewController(statisticsVC, animated: true)
        }

        return navigationController
    }
}

private extension TabBarCoordinator {
    func getTrackersViewController() -> UIViewController {
        guard let pinnedCategoryId = self.serviceSetupper.pinnedCategoryId else { return UIViewController() }

        let trackersSetupper = TrackersViewControllerSetupper(
            trackersCategoryService:         self.serviceSetupper.trackersCategoryService,
            trackersCategoryAddingService:   self.serviceSetupper.trackersCategoryAddingService,
            trackersService:                 self.serviceSetupper.trackersService,
            trackersAddingService:           self.serviceSetupper.trackersAddingService,
            trackersRecordService:           self.serviceSetupper.trackersRecordService,
            trackersCompletingService:       self.serviceSetupper.trackersCompletingService,
            trackersPinningService:          self.serviceSetupper.trackersPinningService,
            alertPresenterService:           self.serviceSetupper.alertPresenterService,
            analyticsService:                self.serviceSetupper.analyticsService,
            pinnedCategoryId:                pinnedCategoryId
        )

        guard let viewController = trackersSetupper.getViewController() else {
            assertionFailure("Cannot get trackers view controller")
            return UIViewController()
        }

        return viewController
    }

    func getStatisticsViewController() -> UIViewController {
        let statisticsSetupper = StatisticsViewControllerSetupper(
            trackersCompletingService: serviceSetupper.trackersCompletingService
        )

        let viewController = statisticsSetupper.getViewController()
        return viewController
    }
}

private extension TabBarCoordinator {
    func styleTabBar() {
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = .Dynamic.whiteDay

        let normalColor = UIColor.Static.gray
        appearance.stackedLayoutAppearance.normal.iconColor = normalColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: normalColor
        ]

        let selectedColor = UIColor.Static.blue
        appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: selectedColor
        ]

        self.tabBarController.tabBar.standardAppearance = appearance
    }
}
