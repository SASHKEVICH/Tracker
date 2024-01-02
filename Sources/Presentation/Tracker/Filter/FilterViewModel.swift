import Foundation

protocol FilterViewControllerDelegate: AnyObject {
    func setCurrentDate()
    func didSelectFilter(category: Category)
}

public final class FilterViewModel {
    public enum FilterMode: Equatable {
        case all(Date)
        case today
        case completed(Date)
        case incompleted(Date)

        var localized: String {
            let localizable = R.string.localizable
            switch self {
            case .all: return localizable.trackerCategoryFlowFilterModeAll()
            case .today: return localizable.trackerCategoryFlowFilterModeToday()
            case .completed: return localizable.trackerCategoryFlowFilterModeCompleted()
            case .incompleted: return localizable.trackerCategoryFlowFilterModeIncompleted()
            }
        }
    }

    weak var delegate: FilterViewControllerDelegate?

    var onCategoriesChanged: Binding?

    var onIsPlaceholderHiddenChanged: Binding?
    var isPlaceholderHidden: Bool { true }

    private let trackersCategoryFactory: TrackersCategoryMapper
    private let trackersService: TrackersServiceFilteringProtocol
    private let chosenDate: Date

    init(
        chosenDate: Date,
        trackersCategoryFactory: TrackersCategoryMapper,
        trackersService: TrackersServiceFilteringProtocol
    ) {
        self.chosenDate = chosenDate
        self.trackersCategoryFactory = trackersCategoryFactory
        self.trackersService = trackersService
    }
}

// MARK: - CategoryViewModelProtocol

extension FilterViewModel: CategoryViewModelProtocol {
    var categories: [CategoryViewController.Model] {
        []
    }

    func didChoose(category: CategoryViewController.Model) {
        guard let mode = self.resolveFiltrationMode(for: category.title) else { return }
        if mode == .today {
            self.delegate?.setCurrentDate()
        }

//        self.delegate?.didSelectFilter(category: category)
        self.trackersService.performFiltering(mode: mode)
    }
}

private extension FilterViewModel {
    func prepareFilter(for mode: FilterMode) -> Category {
        switch mode {
        case .all:
            return self.trackersCategoryFactory.makeCategory(id: StaticUUID.FilterCategories.all, title: mode.localized, isPinning: false)
        case .today:
            return self.trackersCategoryFactory.makeCategory(id: StaticUUID.FilterCategories.today, title: mode.localized, isPinning: false)
        case .completed:
            return self.trackersCategoryFactory.makeCategory(id: StaticUUID.FilterCategories.completed, title: mode.localized, isPinning: false)
        case .incompleted:
            return self.trackersCategoryFactory.makeCategory(id: StaticUUID.FilterCategories.incompleted, title: mode.localized, isPinning: false)
        }
    }

    func resolveFiltrationMode(for title: String) -> FilterMode? {
        switch title {
        case FilterMode.all(self.chosenDate).localized:
            return .all(self.chosenDate)
        case FilterMode.today.localized:
            return .today
        case FilterMode.completed(self.chosenDate).localized:
            return .completed(self.chosenDate)
        case FilterMode.incompleted(self.chosenDate).localized:
            return .incompleted(self.chosenDate)
        default:
            return nil
        }
    }
}
