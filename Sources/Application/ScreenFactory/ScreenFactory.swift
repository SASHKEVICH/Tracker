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

        let pages = self.makeOnboardingPages()
        let delegate = OnboardingPageControllerDelegate(
            viewModel: viewModel,
            pages: pages
        )
        let dataSource = OnboardingPageControllerDataSourceImpl(pages: pages)

        return OnboardingPageViewController(
            viewModel: viewModel,
            pageViewDelegate: delegate,
            pageViewDataSource: dataSource
        )
    }

    func makeOnboardingPages() -> [OnboardingSinglePageViewController] {
        let firstPage = OnboardingSinglePageViewController(
            viewData: OnboardingSinglePageViewController.ViewData(
                image: .Onboarding.first,
                text: R.string.localizable.onboardingPageLabelFirst()
            )
        )

        let secondPage = OnboardingSinglePageViewController(
            viewData: OnboardingSinglePageViewController.ViewData(
                image: .Onboarding.second,
                text: R.string.localizable.onboardingPageLabelSecond()
            )
        )

        return [firstPage, secondPage]
    }
}

// MARK: - StatisticsViewFactory
//extension ScreenFactory: StatisticsViewFactory {
//    func makeStatisticsView() -> StatisticsViewController {
//        let viewModel = StatisticsViewModel(
//            trackersCompletingService: <#T##TrackersCompletingServiceStatisticsProtocol#>
//        )
//
//        return StatisticsViewController(
//            viewModel: viewModel,
//            tableViewHelper: <#T##StatisticsTableViewHelperProtocol#>
//        )
//    }
//}
