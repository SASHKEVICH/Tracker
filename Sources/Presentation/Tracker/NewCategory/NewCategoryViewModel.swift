import Foundation

protocol NewCategoryViewModelProtocol {
    var onIsAddNewCategoryButtonDisabledChanged: Binding? { get set }
    var isAddNewCategoryButtonDisabled: Bool { get }
    func didRecieve(categoryTitle: String)
    func save(categoryTitle: String)
}

final class NewCategoryViewModel {
    var onIsAddNewCategoryButtonDisabledChanged: Binding?
    var isAddNewCategoryButtonDisabled: Bool = true {
        didSet {
            self.onIsAddNewCategoryButtonDisabledChanged?()
        }
    }

    private let trackersCategoryAddingService: TrackersCategoryAddingServiceProtocol

    init(trackersCategoryAddingService: TrackersCategoryAddingServiceProtocol) {
        self.trackersCategoryAddingService = trackersCategoryAddingService
    }
}

// MARK: - NewCategoryViewModelProtocol

extension NewCategoryViewModel: NewCategoryViewModelProtocol {
    func didRecieve(categoryTitle: String) {
        let title = categoryTitle.trimmingCharacters(in: .whitespacesAndNewlines)

        if title.isEmpty {
            self.isAddNewCategoryButtonDisabled = true
        } else {
            self.isAddNewCategoryButtonDisabled = false
        }
    }

    func save(categoryTitle: String) {
        self.trackersCategoryAddingService.addCategory(title: categoryTitle)
    }
}
