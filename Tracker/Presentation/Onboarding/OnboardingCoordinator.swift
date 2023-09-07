import UIKit

protocol OnboardingCoordinatorProtocol: Coordinator {
    func showOnboardingViewController()
}

final class OnboardingCoordinator: OnboardingCoordinatorProtocol {
    let navigationController: UINavigationController

    weak var finishDelegate: CoordinatorFinishDelegate?
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType { .onboarding }

    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        self.showOnboardingViewController()
    }

    func showOnboardingViewController() {
        let onboardingHelper = OnboardingViewControllerHelper()
        let onboardingPresenter = OnboardingViewPresenter(helper: onboardingHelper)

        onboardingPresenter.onNavigateToTabBar = { [weak self] _ in
            self?.finish()
        }

        let onboardingViewController = OnboardingViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )

        onboardingViewController.presenter = onboardingPresenter
        onboardingPresenter.view = onboardingViewController

        self.navigationController.pushViewController(onboardingViewController, animated: false)
    }
}
