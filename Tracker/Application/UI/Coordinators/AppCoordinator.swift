import UIKit

protocol AppCoordinatorProtocol: Coordinator {
    func showOnboardingFlow()
    func showMainFlow()
}

final class AppCoordinator: AppCoordinatorProtocol {
    var childCoordinators: [Coordinator] = []

    private let coordinatorFactory: CoordinatorFactoryProtocol
    private let router: Routerable

    init(coordinatorFactory: CoordinatorFactoryProtocol, router: Routerable) {
        self.coordinatorFactory = coordinatorFactory
        self.router = router
    }

    func start() {
    }

    func showOnboardingFlow() {
    }

    func showMainFlow() {
    }
}
