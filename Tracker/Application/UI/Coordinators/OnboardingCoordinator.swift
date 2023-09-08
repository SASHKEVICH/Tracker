import UIKit

final class OnboardingCoordinator: BaseCoordinator {
    var finishFlow: VoidAction?

    private let router: Routerable
    private let screenFactory: ScreenFactoryProtocol

    init(router: Routerable, screenFactory: ScreenFactoryProtocol) {
        self.router = router
        self.screenFactory = screenFactory
    }

    override func start() {
        self.showOnboardingViewController()
    }

    func showOnboardingViewController() {
        let onboardingScreen = self.screenFactory.makeOnboardingScreen()
        onboardingScreen.onEndOnboarding = { [weak self] in
            self?.finishFlow?()
        }

        onboardingScreen.pages = [
            self.screenFactory.makeOnboardingPage(index: .first),
            self.screenFactory.makeOnboardingPage(index: .second)
        ]

        self.router.setRootModule(onboardingScreen, hideBar: true)
    }
}
