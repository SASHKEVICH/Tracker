import UIKit

enum AppChildCoordinator {
    case onboarding
    case main
}

final class AppCoordinator: Coordinator {

    private let window: UIWindow
    private let navigationController: UINavigationController

    private let onboardingViewFactory: OnboardingViewFactory
    private let checkFirstLaunchUseCase: CheckFirstLaunchUseCaseProtocol

    private var childCoordinators: [AppChildCoordinator: Coordinator] = [:]

    init(
        window: UIWindow,
        onboardingViewFactory: OnboardingViewFactory,
        checkFirstLaunchUseCase: CheckFirstLaunchUseCaseProtocol
    ) {
        self.window = window
        self.onboardingViewFactory = onboardingViewFactory
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
            self.showMain()
        }
    }
}

private extension AppCoordinator {
    func showOnboarding() {
        let view = onboardingViewFactory.makeOnboardingView {
            print("show main")
        }

        self.navigationController.pushViewController(view, animated: false)
        self.navigationController.isNavigationBarHidden = true
        self.navigationController.hidesBottomBarWhenPushed = true
    }

    func showMain() {

    }
}
