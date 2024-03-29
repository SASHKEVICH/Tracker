import UIKit

protocol CategoryRouterProtocol {
    func navigateToNewCategoryScreen(from viewController: CategoryViewController)
}

final class CategoryRouter {
    private let trackersCategoryAddingService: TrackersCategoryAddingServiceProtocol

    init(trackersCategoryAddingService: TrackersCategoryAddingServiceProtocol) {
        self.trackersCategoryAddingService = trackersCategoryAddingService
    }
}

// MARK: - CategoryRouterProtocol

extension CategoryRouter: CategoryRouterProtocol {
    func navigateToNewCategoryScreen(from viewController: CategoryViewController) {
        let viewModel = NewCategoryViewModel(trackersCategoryAddingService: self.trackersCategoryAddingService)
        let vc = NewCategoryViewController(viewModel: viewModel)

        vc.emptyTap = { [weak vc] in
            vc?.view.endEditing(true)
        }
        vc.delegate = viewController

        viewController.present(vc, animated: true)
    }
}
