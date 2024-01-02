import UIKit

final class CoordinatorFactory {

    private let window: UIWindow
    private let appFactory: AppFactory
    private let screenFactory: ScreenFactory

    init(
        window: UIWindow,
        appFactory: AppFactory,
        screenFactory: ScreenFactory
    ) {
        self.window = window
        self.appFactory = appFactory
        self.screenFactory = screenFactory
    }

    func makeAppCoordinator() -> AppCoordinator {
        return AppCoordinator(
            window: self.window,
            onboardingViewFactory: self.screenFactory,
            checkFirstLaunchUseCase: self.appFactory.makeCheckFirstLaunchUseCase()
        )
    }
}
