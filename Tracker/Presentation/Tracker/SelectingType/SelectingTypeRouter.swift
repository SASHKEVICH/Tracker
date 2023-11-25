import Foundation

protocol SelectingTypeRouterProtocol {
    func navigateToTrackerScreen()
    func navigateToIrregularEventScreen()
}

final class SelectingTypeRouter {
    private weak var viewController: SelectingTypeViewController?
    private let trackersAddingService: TrackersAddingServiceProtocol
    private let trackersCategoryAddingService: TrackersCategoryAddingServiceProtocol
    private let getCategoriesUseCase: GetCategoriesUseCaseProtocol
    private let pinnedCategoryId: UUID?

    init(
        viewController: SelectingTypeViewController,
        trackersAddingService: TrackersAddingServiceProtocol,
        trackersCategoryAddingService: TrackersCategoryAddingServiceProtocol,
        getCategoriesUseCase: GetCategoriesUseCaseProtocol,
        pinnedCategoryId: UUID?

    ) {
        self.viewController = viewController
        self.trackersAddingService = trackersAddingService
        self.trackersCategoryAddingService = trackersCategoryAddingService
        self.getCategoriesUseCase = getCategoriesUseCase
        self.pinnedCategoryId = pinnedCategoryId
    }
}

// MARK: - SelectingTypeRouterProtocol

extension SelectingTypeRouter: SelectingTypeRouterProtocol {
    func navigateToTrackerScreen() {
        self.presentAddingViewController(trackerType: .tracker)
    }

    func navigateToIrregularEventScreen() {
        self.presentAddingViewController(trackerType: .irregularEvent)
    }
}

private extension SelectingTypeRouter {
    func presentAddingViewController(trackerType: OldTrackerEntity.TrackerType) {
        let optionsHelper = OptionsTableViewHelper()
        let textFieldHelper = TitleTextFieldHelper()
        let colorsHelper = ColorsCollectionViewHelper()
        let emojisHelper = EmojisCollectionViewHelper()

        let view = AddingView(
            optionsTableViewHelper: optionsHelper,
            titleTextFieldHelper: textFieldHelper,
            colorsHelper: colorsHelper,
            emojisHelper: emojisHelper,
            flow: .add
        )

        let router = AddingRouter(
            trackersCategoryAddingService: self.trackersCategoryAddingService,
            getCategoriesUseCase: self.getCategoriesUseCase,
            pinnedCategoryId: self.pinnedCategoryId
        )

        let optionsTitle = self.prepareOptionsTitles(for: trackerType)
        let viewControllerTitle = self.prepareAddingViewControllerTitle(for: trackerType)

        let viewModel = AddingViewModel(
            trackersAddingService: self.trackersAddingService,
            trackerType: trackerType,
            optionTitles: optionsTitle,
            viewControllerTitle: viewControllerTitle
        )

        let vc = AddingViewController(router: router, view: view, viewModel: viewModel)

        optionsHelper.delegate = vc
        colorsHelper.delegate = vc
        emojisHelper.delegate = vc

        vc.emptyTap = { [weak vc] in
            vc?.view.endEditing(true)
        }

        self.viewController?.present(vc, animated: true)
    }
}

private extension SelectingTypeRouter {
    func prepareOptionsTitles(for type: OldTrackerEntity.TrackerType) -> [String] {
        let localizable = R.string.localizable
        let categoryTitle = localizable.trackerAddingOptionTitleCategory()
        switch type {
        case .tracker:
            let scheduleTitle = localizable.trackerAddingOptionTitleSchedule()
            return [categoryTitle, scheduleTitle]
        case .irregularEvent:
            return [categoryTitle]
        }
    }

    func prepareAddingViewControllerTitle(for type: OldTrackerEntity.TrackerType) -> String {
        let localizable = R.string.localizable
        switch type {
        case .tracker:
            return localizable.trackerAddingTrackerViewControllerTitle()
        case .irregularEvent:
            return localizable.trackerAddingIrregularEventViewControllerTitle()
        }
    }
}
