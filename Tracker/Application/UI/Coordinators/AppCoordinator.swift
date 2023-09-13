import UIKit

final class AppCoordinator: BaseCoordinator {
    private let coordinatorFactory: CoordinatorFactoryProtocol
    private let router: Routerable

    private var isFirstLaunch = true

    init(coordinatorFactory: CoordinatorFactoryProtocol, router: Routerable) {
        self.coordinatorFactory = coordinatorFactory
        self.router = router
    }

    override func start() {
        if self.isFirstLaunch {
            self.showOnboardingFlow()
            self.isFirstLaunch = false
            return
        }

        self.showMainFlow()
    }

    func showOnboardingFlow() {
        let onboardingCoordinator = self.coordinatorFactory.makeOnboardingCoordinator(router: self.router)
        onboardingCoordinator.finishFlow = { [weak self, weak onboardingCoordinator] in
            self?.removeDependency(onboardingCoordinator)
            self?.showMainFlow()
        }

        self.addDependency(onboardingCoordinator)
        onboardingCoordinator.start()
    }

    func showMainFlow() {
    }
}
