import UIKit

protocol AddingRouterProtocol {
    func navigateToScheduleScreen(selectedWeekDays: Set<WeekDay>, from viewController: UIViewController)
    func navigateToCategoryScreen(selectedCategory: Category?, from viewController: UIViewController)
    func navigateToMainScreen()
}

final class AddingRouter {

    private let trackersCategoryAddingService: TrackersCategoryAddingServiceProtocol
    private let getCategoriesUseCase: GetCategoriesUseCaseProtocol
    private let pinnedCategoryId: UUID?

    init(
        trackersCategoryAddingService: TrackersCategoryAddingServiceProtocol,
        getCategoriesUseCase: GetCategoriesUseCaseProtocol,
        pinnedCategoryId: UUID? = nil
    ) {
        self.trackersCategoryAddingService = trackersCategoryAddingService
        self.getCategoriesUseCase = getCategoriesUseCase
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

    func navigateToCategoryScreen(selectedCategory: Category?, from viewController: UIViewController) {
        let viewModel = CategoryViewModel(
            getCategoriesUseCase: self.getCategoriesUseCase
        )
        viewModel.delegate = viewController as? CategoryViewControllerDelegate

        let helper = CategoryTableViewHelper()
        let router = CategoryRouter(trackersCategoryAddingService: self.trackersCategoryAddingService)

        let vc = CategoryViewController(
            viewModel: viewModel,
            helper: helper,
            router: router
        )

        viewController.present(vc, animated: true)
    }

    func navigateToMainScreen() {
        UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}
