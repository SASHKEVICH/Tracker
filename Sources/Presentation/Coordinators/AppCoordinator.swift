import UIKit

enum AppChildCoordinator {
    case onboarding
    case main
}

final class AppCoordinator: Coordinator {

    private let window: UIWindow
    private let navigationController: UINavigationController

    private let screenFactory: ScreenFactory
    private let checkFirstLaunchUseCase: CheckFirstLaunchUseCaseProtocol

    private var childCoordinators: [AppChildCoordinator: Coordinator] = [:]

    init(
        window: UIWindow,
        screenFactory: ScreenFactory,
        checkFirstLaunchUseCase: CheckFirstLaunchUseCaseProtocol
    ) {
        self.window = window
        self.screenFactory = screenFactory
        self.checkFirstLaunchUseCase = checkFirstLaunchUseCase

        self.navigationController = UINavigationController()
        self.window.rootViewController = self.navigationController
        self.window.makeKeyAndVisible()
    }

    func start() {
        let didAppLaunchOnce = self.checkFirstLaunchUseCase.execute()

        if didAppLaunchOnce {
            self.showOnboarding()
        } else {
//            self.showMain()
        }
    }
}

private extension AppCoordinator {
    func showOnboarding() {
        let view = screenFactory.makeOnboardingView { [weak self] in
//            self?.showMain()
        }

        self.navigationController.pushViewController(view, animated: false)
        self.navigationController.isNavigationBarHidden = true
        self.navigationController.hidesBottomBarWhenPushed = true
    }

//    func showMain() {
//        let mainCoordinator = MainTabBarCoordinator(
//            tabBarController: self.navigationController,
//            screenFactory: self.screenFactory as! MainViewFactory
//        )
//        self.childCoordinators[.main] = mainCoordinator
//        mainCoordinator.start()
//    }
}
