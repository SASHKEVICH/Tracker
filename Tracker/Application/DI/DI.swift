import UIKit

final class DI {
    private let screenFactory: ScreenFactoryProtocol
    private let coordinatorFactory: CoordinatorFactoryProtocol

    init() {
        self.screenFactory = ScreenFactory()
        self.coordinatorFactory = CoordinatorFactory(screenFactory: self.screenFactory)
    }
}

protocol AppFactory {
    func makeKeyWindowWithCoordinator() -> (UIWindow, Coordinator)
}

// MARK: - AppFactory
extension DI: AppFactory {
    func makeKeyWindowWithCoordinator() -> (UIWindow, Coordinator) {
        let window = UIWindow()

        let rootVC = UINavigationController()
        rootVC.navigationBar.prefersLargeTitles = true

        let router = Router(rootViewController: rootVC)
        let coordinator = self.coordinatorFactory.makeAppCoordinator(router: router)

        window.rootViewController = rootVC
        return (window, coordinator)
    }
}

protocol ScreenFactoryProtocol {
    func makeOnboardingScreen()
}

final class ScreenFactory: ScreenFactoryProtocol {
    private weak var di: DI?
    fileprivate init() {}

    func makeOnboardingScreen() {

    }
}

protocol CoordinatorFactoryProtocol {
    func makeAppCoordinator(router: Routerable) -> AppCoordinator
}

final class CoordinatorFactory: CoordinatorFactoryProtocol {
    private let screenFactory: ScreenFactoryProtocol

    fileprivate init(screenFactory: ScreenFactoryProtocol) {
        self.screenFactory = screenFactory
    }

    func makeAppCoordinator(router: Routerable) -> AppCoordinator {
        AppCoordinator(coordinatorFactory: self, router: router)
    }
}
