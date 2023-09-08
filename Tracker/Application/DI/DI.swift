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
    func makeKeyWindowWithCoordinator(window: UIWindow) -> Coordinator
}

// MARK: - AppFactory
extension DI: AppFactory {
    func makeKeyWindowWithCoordinator(window: UIWindow) -> Coordinator {
        let rootVC = UINavigationController()
        rootVC.navigationBar.prefersLargeTitles = true

        let router = Router(rootViewController: rootVC)
        let coordinator = self.coordinatorFactory.makeAppCoordinator(router: router)

        window.rootViewController = rootVC
        return coordinator
    }
}

protocol ScreenFactoryProtocol {
    func makeOnboardingScreen() -> OnboardingViewController<OnboardingView>
    func makeOnboardingPage(index: OnboardingPage.Index) -> OnboardingPage
}

final class ScreenFactory: ScreenFactoryProtocol {
    private weak var di: DI?
    fileprivate init() {}

    func makeOnboardingScreen() -> OnboardingViewController<OnboardingView> {
        OnboardingViewController<OnboardingView>()
    }

    func makeOnboardingPage(index: OnboardingPage.Index) -> OnboardingPage {
        let inputData = self.resolveOnboardingPageWith(index: index)
        return OnboardingPage(inputData: inputData)
    }

    private func resolveOnboardingPageWith(index: OnboardingPage.Index) -> OnboardingPage.InputData {
        switch index {
        case .first:
            return OnboardingPage.InputData(
                image: .Onboarding.first,
                onboardingText: R.string.localizable.onboardingPageLabelFirst()
            )
        case .second:
            return OnboardingPage.InputData(
                image: .Onboarding.second,
                onboardingText: R.string.localizable.onboardingPageLabelSecond()
            )
        }
    }
}

protocol CoordinatorFactoryProtocol {
    func makeAppCoordinator(router: Routerable) -> AppCoordinator
    func makeOnboardingCoordinator(router: Routerable) -> OnboardingCoordinator
}

final class CoordinatorFactory: CoordinatorFactoryProtocol {
    private let screenFactory: ScreenFactoryProtocol

    fileprivate init(screenFactory: ScreenFactoryProtocol) {
        self.screenFactory = screenFactory
    }

    func makeAppCoordinator(router: Routerable) -> AppCoordinator {
        AppCoordinator(coordinatorFactory: self, router: router)
    }

    func makeOnboardingCoordinator(router: Routerable) -> OnboardingCoordinator {
        OnboardingCoordinator(router: router, screenFactory: self.screenFactory)
    }
}
