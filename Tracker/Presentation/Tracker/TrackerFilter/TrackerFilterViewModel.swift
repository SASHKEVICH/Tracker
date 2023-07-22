//
//  TrackerFilterViewModel.swift
//  Tracker
//
//  Created by Александр Бекренев on 14.07.2023.
//

import Foundation

protocol TrackerFilterViewControllerDelegate: AnyObject {
    func setCurrentDate()
    func didSelectFilter(category: TrackerCategory)
}

public final class TrackerFilterViewModel {
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

    weak var delegate: TrackerFilterViewControllerDelegate?

    var onCategoriesChanged: Binding?
    var categories: [TrackerCategory] {
        let allTrackers = prepareFilter(for: .all(chosenDate))
        let todayTrackers = prepareFilter(for: .today)
        let completedTrackers = prepareFilter(for: .completed(chosenDate))
        let incompletedTrackers = prepareFilter(for: .incompleted(chosenDate))

        return [allTrackers, todayTrackers, completedTrackers, incompletedTrackers]
    }

    var onIsPlaceholderHiddenChanged: Binding?
    var isPlaceholderHidden: Bool { true }

    private let trackersCategoryFactory: TrackersCategoryFactory
    private let trackersService: TrackersServiceFilteringProtocol
    private let chosenDate: Date

    init(
        chosenDate: Date,
        trackersCategoryFactory: TrackersCategoryFactory,
        trackersService: TrackersServiceFilteringProtocol
    ) {
        self.chosenDate = chosenDate
        self.trackersCategoryFactory = trackersCategoryFactory
        self.trackersService = trackersService
    }
}

// MARK: - TrackerCategoryViewModelProtocol

extension TrackerFilterViewModel: TrackerCategoryViewModelProtocol {
    func didChoose(category: TrackerCategory) {
        guard let mode = resolveFiltrationMode(for: category.title) else { return }
        if mode == .today {
            delegate?.setCurrentDate()
        }

        delegate?.didSelectFilter(category: category)
        trackersService.performFiltering(mode: mode)
    }
}

private extension TrackerFilterViewModel {
    func prepareFilter(for mode: FilterMode) -> TrackerCategory {
        switch mode {
        case .all:
            return trackersCategoryFactory.makeCategory(id: StaticUUID.FilterCategories.all, title: mode.localized, isPinning: false)
        case .today:
            return trackersCategoryFactory.makeCategory(id: StaticUUID.FilterCategories.today, title: mode.localized, isPinning: false)
        case .completed:
            return trackersCategoryFactory.makeCategory(id: StaticUUID.FilterCategories.completed, title: mode.localized, isPinning: false)
        case .incompleted:
            return trackersCategoryFactory.makeCategory(id: StaticUUID.FilterCategories.incompleted, title: mode.localized, isPinning: false)
        }
    }

    func resolveFiltrationMode(for title: String) -> FilterMode? {
        switch title {
        case FilterMode.all(chosenDate).localized:
            return .all(chosenDate)
        case FilterMode.today.localized:
            return .today
        case FilterMode.completed(chosenDate).localized:
            return .completed(chosenDate)
        case FilterMode.incompleted(chosenDate).localized:
            return .incompleted(chosenDate)
        default:
            return nil
        }
    }
}
