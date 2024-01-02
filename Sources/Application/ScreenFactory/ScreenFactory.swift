import Foundation

final class ScreenFactory {

    private let appFactory: AppFactory

    init(appFactory: AppFactory) {
        self.appFactory = appFactory
    }
}

// MARK: - CategoriesViewFactory

extension ScreenFactory: CategoriesViewFactory {
    func makeCategoriesView() -> CategoryViewController {
        let viewModel = CategoryViewModel(
            getCategoriesUseCase: appFactory.makeGetCategoriesUseCase()
        )

        return CategoryViewController(
            viewModel: viewModel,
            helper: CategoryTableViewHelper(),
            router: nil
        )
    }
}

// MARK: - OnboardingViewFactory

extension ScreenFactory: OnboardingViewFactory {
    func makeOnboardingView(
        finishCompletion: @escaping () -> Void
    ) -> OnboardingPageViewController {
        let viewModel = OnboardingViewModel(finishCompletion: finishCompletion)

        return OnboardingPageViewController(viewModel: viewModel)
    }
}
