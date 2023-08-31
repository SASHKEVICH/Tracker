import UIKit

protocol AppCoordinatorProtocol: Coordinator {
    func showOnboardingFlow()
    func showMainFlow()
}

final class AppCoordinator: AppCoordinatorProtocol {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType { .app }

    private let serviceSetupper: ServiceSetupperProtocol

    init(_ navigationController: UINavigationController, serviceSetupper: ServiceSetupperProtocol) {
        self.navigationController = navigationController
        self.serviceSetupper = serviceSetupper
        self.navigationController.setNavigationBarHidden(true, animated: true)
    }

    func start() {
        self.showMainFlow()
    }

    func showOnboardingFlow() {

    }

    func showMainFlow() {
        let tabBarCoordinator = TabBarCoordinator(
            self.navigationController,
            serviceSetupper: self.serviceSetupper
        )
        tabBarCoordinator.finishDelegate = self
        tabBarCoordinator.start()
        self.childCoordinators.append(tabBarCoordinator)
    }
}

// MARK: - CoordinatorFinishDelegate

extension AppCoordinator: CoordinatorFinishDelegate {
    func coordinatorFinishDelegate(childCoordinator: Coordinator, didFinish: Bool = true) {
        self.childCoordinators = self.childCoordinators.filter({ $0.type != childCoordinator.type })
    }
}
