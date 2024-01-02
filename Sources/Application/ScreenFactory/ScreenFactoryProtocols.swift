import Foundation

protocol CategoriesViewFactory {
    func makeCategoriesView() -> CategoryViewController
}

protocol OnboardingViewFactory {
    func makeOnboardingView(
        finishCompletion: @escaping () -> Void
    ) -> OnboardingPageViewController
}
