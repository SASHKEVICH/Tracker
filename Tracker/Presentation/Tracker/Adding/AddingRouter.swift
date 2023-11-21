import UIKit

protocol AddingRouterProtocol {
    func navigateToScheduleScreen(selectedWeekDays: Set<WeekDay>, from viewController: UIViewController)
    func navigateToCategoryScreen(selectedCategory: TrackerCategory?, from viewController: UIViewController)
    func navigateToMainScreen()
}

final class AddingRouter {
    private let trackersCategoryService: TrackersCategoryServiceProtocol
    private let trackersCategoryAddingService: TrackersCategoryAddingServiceProtocol
    private let pinnedCategoryId: UUID?

    init(
        trackersCategoryService: TrackersCategoryServiceProtocol,
        trackersCategoryAddingService: TrackersCategoryAddingServiceProtocol,
        pinnedCategoryId: UUID? = nil
    ) {
        self.trackersCategoryService = trackersCategoryService
        self.trackersCategoryAddingService = trackersCategoryAddingService
        self.pinnedCategoryId = pinnedCategoryId
    }
}

// MARK: - AddingRouterProtocol

extension AddingRouter: AddingRouterProtocol {
    func navigateToScheduleScreen(selectedWeekDays: Set<WeekDay>, from viewController: UIViewController) {
        let vc = SelectingScheduleViewController()
        vc.delegate = viewController as? SelectingScheduleViewControllerDelegate

        let presenter = SelectingSchedulePresenter()
        vc.presenter = presenter
        presenter.view = vc

        presenter.selectedWeekDays = selectedWeekDays

        viewController.present(vc, animated: true)
    }

    func navigateToCategoryScreen(selectedCategory: TrackerCategory?, from viewController: UIViewController) {
        let viewModel = CategoryViewModel(
            trackersCategoryService: self.trackersCategoryService,
            pinnedCategoryId: self.pinnedCategoryId
        )
        viewModel.delegate = viewController as? CategoryViewControllerDelegate

        let helper = CategoryTableViewHelper()
        let router = CategoryRouter(trackersCategoryAddingService: self.trackersCategoryAddingService)

        let vc = CategoryViewController(
            viewModel: viewModel,
            helper: helper,
            router: router,
            flow: .normal,
            selectedCategory: selectedCategory
        )

        viewController.present(vc, animated: true)
    }

    func navigateToMainScreen() {
        UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}
