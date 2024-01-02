import UIKit

final class MainCoordinator: Coordinator {

    // MARK: - Private Properties

    private let navigationController: UINavigationController
    private let screenFactory: ScreenFactory

    // MARK: - Init

    init(
        navigationController: UINavigationController,
        screenFactory: ScreenFactory
    ) {
        self.navigationController = navigationController
        self.screenFactory = screenFactory
    }

    func start() {

    }
}
