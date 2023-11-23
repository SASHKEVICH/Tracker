import Foundation

protocol CategoryViewModelProtocol {
    var onCategoriesChanged: Binding? { get set }
    var categories: [Category] { get }

    var onIsPlaceholderHiddenChanged: Binding? { get set }
    var isPlaceholderHidden: Bool { get }
    func didChoose(category: Category)
}

final class CategoryViewModel {
    weak var delegate: CategoryViewControllerDelegate?

    var onCategoriesChanged: Binding?
    var categories: [Category] = [] {
        didSet {
            self.onCategoriesChanged?()
            self.shouldHidePlaceholder()
        }
    }

    var onIsPlaceholderHiddenChanged: Binding?
    var isPlaceholderHidden: Bool = true {
        didSet {
            self.onIsPlaceholderHiddenChanged?()
        }
    }

    private let pinnedCategoryId: UUID?

    private var trackersCategoryService: TrackersCategoryServiceProtocol

    init(trackersCategoryService: TrackersCategoryServiceProtocol, pinnedCategoryId: UUID? = nil) {
        self.trackersCategoryService = trackersCategoryService
        self.pinnedCategoryId = pinnedCategoryId
        self.trackersCategoryService.trackersCategoryDataProviderDelegate = self

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.categories = self.getCategoriesFromStore()
        }
    }
}

// MARK: - CategoryViewModelProtocol

extension CategoryViewModel: CategoryViewModelProtocol {
    func didChoose(category: Category) {
        self.delegate?.didRecieveCategory(category)
    }
}

// MARK: - TrackersCategoryDataProviderDelegate

extension CategoryViewModel: TrackersCategoryDataProviderDelegate {
    func storeDidUpdate() {
        self.categories = self.getCategoriesFromStore()
    }
}

private extension CategoryViewModel {
    func shouldHidePlaceholder() {
        self.isPlaceholderHidden = self.categories.isEmpty == false
    }

    func getCategoriesFromStore() -> [Category] {
        let categories = self.trackersCategoryService.categories
        return categories.filter { $0.id != self.pinnedCategoryId }
    }
}
