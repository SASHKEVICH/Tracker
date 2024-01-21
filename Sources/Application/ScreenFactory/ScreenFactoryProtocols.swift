import Foundation

protocol CategoriesViewFactory {
    func makeCategoriesView() -> CategoryViewController
}

protocol OnboardingViewFactory {
    func makeOnboardingView(
        finishCompletion: @escaping () -> Void
    ) -> OnboardingPageViewController

    func makeOnboardingPages() -> [OnboardingSinglePageViewController]
}

protocol MainViewFactory {
    func makeMainView()
}

protocol StatisticsViewFactory {
    func makeStatisticsView() -> StatisticsViewController
}
