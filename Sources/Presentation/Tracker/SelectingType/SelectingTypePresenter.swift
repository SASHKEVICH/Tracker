import Foundation

protocol SelectingTypePresenterProtocol {
    func navigateToTrackerScreen()
    func navigateToIrregularEventScreen()
}

final class SelectingTypePresenter {
    private let router: SelectingTypeRouterProtocol

    init(router: SelectingTypeRouterProtocol) {
        self.router = router
    }
}

// MARK: - SelectingTypePresenterProtocol

extension SelectingTypePresenter: SelectingTypePresenterProtocol {
    func navigateToTrackerScreen() {
        self.router.navigateToTrackerScreen()
    }

    func navigateToIrregularEventScreen() {
        self.router.navigateToIrregularEventScreen()
    }
}
