import UIKit

protocol AppCoordinatorProtocol: Coordinator {
    func showOnboardingFlow()
    func showMainFlow()
}

final class AppCoordinator: AppCoordinatorProtocol {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    private let firstLaunchService: FirstLaunchServiceProtocol
    private let serviceSetupper: ServiceSetupperProtocol

    init(
        _ navigationController: UINavigationController,
        firstLaunchService: FirstLaunchServiceProtocol,
        serviceSetupper: ServiceSetupperProtocol
    ) {
        self.navigationController = navigationController
        self.firstLaunchService = firstLaunchService
        self.serviceSetupper = serviceSetupper
        self.navigationController.setNavigationBarHidden(true, animated: true)
    }

    func start() {
        let didAppAlreadyLaunchOnce = self.firstLaunchService.isAppAlreadyLaunchedOnce
        if !didAppAlreadyLaunchOnce {
            self.showOnboardingFlow()
        } else {
            self.showMainFlow()
        }
    }

    func showOnboardingFlow() {
        let onboardingCoordinator = OnboardingCoordinator(self.navigationController)
        onboardingCoordinator.start()
        self.childCoordinators.append(onboardingCoordinator)
    }

    func showMainFlow() {
        let tabBarCoordinator = TabBarCoordinator(
            self.navigationController,
            serviceSetupper: self.serviceSetupper
        )
        tabBarCoordinator.start()
        self.childCoordinators.append(tabBarCoordinator)
    }
}
