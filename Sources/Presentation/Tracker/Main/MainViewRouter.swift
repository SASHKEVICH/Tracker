import UIKit

protocol MainViewRouterProtocol {
    func navigateToTrackerTypeScreen()
    func navigateToFilterScreen(chosenDate: Date, selectedFilter: Category?)
    func navigateToEditTrackerScreen(tracker: OldTrackerEntity)
}

final class MainViewRouter {
    private weak var viewController: UIViewController?
    private let trackersCategoryAddingService: TrackersCategoryAddingServiceProtocol
    private let trackersService: TrackersServiceFilteringProtocol
    private let trackersAddingService: TrackersAddingServiceProtocol
    private let trackersRecordService: TrackersRecordServiceProtocol
    private let trackersCompletingService: TrackersCompletingServiceProtocol
    private let getCategoriesUseCase: GetCategoriesUseCaseProtocol
    private let pinnedCategoryId: UUID

    init(
        viewController: UIViewController,
        trackersCategoryAddingService: TrackersCategoryAddingServiceProtocol,
        trackersService: TrackersServiceFilteringProtocol,
        trackersAddingService: TrackersAddingServiceProtocol,
        trackersRecordService: TrackersRecordServiceProtocol,
        trackersCompletingService: TrackersCompletingServiceProtocol,
        getCategoriesUseCase: GetCategoriesUseCaseProtocol,
        pinnedCategoryId: UUID
    ) {
        self.viewController = viewController
        self.trackersCategoryAddingService = trackersCategoryAddingService
        self.trackersService = trackersService
        self.trackersAddingService = trackersAddingService
        self.trackersRecordService = trackersRecordService
        self.trackersCompletingService = trackersCompletingService
        self.getCategoriesUseCase = getCategoriesUseCase
        self.pinnedCategoryId = pinnedCategoryId
    }
}

// MARK: - MainViewRouterProtocol

extension MainViewRouter: MainViewRouterProtocol {
    func navigateToTrackerTypeScreen() {
        let vc = SelectingTypeViewController()
        let router = SelectingTypeRouter(
            viewController: vc,
            trackersAddingService: self.trackersAddingService,
            trackersCategoryAddingService: self.trackersCategoryAddingService,
            getCategoriesUseCase: self.getCategoriesUseCase,
            pinnedCategoryId: self.pinnedCategoryId
        )
        let presenter = SelectingTypePresenter(router: router)

        vc.presenter = presenter

        self.viewController?.present(vc, animated: true)
    }

    func navigateToFilterScreen(chosenDate: Date, selectedFilter: Category?) {
        let trackersFactory = TrackersFactory()
        let categoryFactory = TrackersCategoryMapper(trackersFactory: trackersFactory)

        let viewModel = FilterViewModel(
            chosenDate: chosenDate,
            trackersCategoryFactory: categoryFactory,
            trackersService: self.trackersService
        )
        viewModel.delegate = self.viewController as? FilterViewControllerDelegate

        let helper = CategoryTableViewHelper()
        let vc = CategoryViewController(
            viewModel: viewModel,
            helper: helper,
            router: nil
        )

        self.viewController?.present(vc, animated: true)
    }

    func navigateToEditTrackerScreen(tracker: OldTrackerEntity) {
        let router = AddingRouter(
            trackersCategoryAddingService: self.trackersCategoryAddingService,
            getCategoriesUseCase: self.getCategoriesUseCase,
            pinnedCategoryId: self.pinnedCategoryId
        )

        let optionsHelper = OptionsTableViewHelper()
        let textFieldHelper = TitleTextFieldHelper()
        let colorsHelper = ColorsCollectionViewHelper()
        let emojisHelper = EmojisCollectionViewHelper()

        let viewModel = EditingViewModel(
            trackersAddingService: self.trackersAddingService,
            trackersRecordService: self.trackersRecordService,
            trackersCompletingService: self.trackersCompletingService,
            tracker: tracker
        )

        let view = AddingView(
            optionsTableViewHelper: optionsHelper,
            titleTextFieldHelper: textFieldHelper,
            colorsHelper: colorsHelper,
            emojisHelper: emojisHelper,
            flow: .edit
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
