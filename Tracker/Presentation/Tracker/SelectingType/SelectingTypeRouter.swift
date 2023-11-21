import Foundation

protocol SelectingTypeRouterProtocol {
    func navigateToTrackerScreen()
    func navigateToIrregularEventScreen()
}

final class SelectingTypeRouter {
    private weak var viewController: SelectingTypeViewController?
    private let trackersAddingService: TrackersAddingServiceProtocol
    private let trackersCategoryService: TrackersCategoryServiceProtocol
    private let trackersCategoryAddingService: TrackersCategoryAddingServiceProtocol
    private let pinnedCategoryId: UUID?

    init(
        viewController: SelectingTypeViewController,
        trackersAddingService: TrackersAddingServiceProtocol,
        trackersCategoryService: TrackersCategoryServiceProtocol,
        trackersCategoryAddingService: TrackersCategoryAddingServiceProtocol,
        pinnedCategoryId: UUID?

    ) {
        self.viewController = viewController
        self.trackersAddingService = trackersAddingService
        self.trackersCategoryService = trackersCategoryService
        self.trackersCategoryAddingService = trackersCategoryAddingService
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
    func presentAddingViewController(trackerType: Tracker.TrackerType) {
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
            trackersCategoryService: self.trackersCategoryService,
            trackersCategoryAddingService: self.trackersCategoryAddingService,
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
    func prepareOptionsTitles(for type: Tracker.TrackerType) -> [String] {
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

    func prepareAddingViewControllerTitle(for type: Tracker.TrackerType) -> String {
        let localizable = R.string.localizable
        switch type {
        case .tracker:
            return localizable.trackerAddingTrackerViewControllerTitle()
        case .irregularEvent:
            return localizable.trackerAddingIrregularEventViewControllerTitle()
        }
    }
}
