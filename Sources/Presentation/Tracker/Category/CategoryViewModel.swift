import Foundation

protocol CategoryViewModelProtocol {
    var onCategoriesChanged: Binding? { get set }
    var categories: [CategoryViewController.Model] { get }

    var onIsPlaceholderHiddenChanged: Binding? { get set }
    var isPlaceholderHidden: Bool { get }
    func didChoose(category: CategoryViewController.Model)
}

final class CategoryViewModel {
    weak var delegate: CategoryViewControllerDelegate?

    var onCategoriesChanged: Binding?
    var categories: [CategoryViewController.Model] = [] {
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

    private let getCategoriesUseCase: GetCategoriesUseCaseProtocol

    init(getCategoriesUseCase: GetCategoriesUseCaseProtocol) {
        self.getCategoriesUseCase = getCategoriesUseCase
        self.getCategoriesFromStore()
    }
}

// MARK: - CategoryViewModelProtocol

extension CategoryViewModel: CategoryViewModelProtocol {
    func didChoose(category: CategoryViewController.Model) {
//        self.delegate?.didRecieveCategory(category)
    }
}

// MARK: - TrackersCategoryDataProviderDelegate

extension CategoryViewModel: TrackersCategoryDataProviderDelegate {
    func storeDidUpdate() {
//        self.categories = self.getCategoriesFromStore()
    }
}

private extension CategoryViewModel {
    func shouldHidePlaceholder() {
        self.isPlaceholderHidden = self.categories.isEmpty == false
    }

    func getCategoriesFromStore() {
        self.getCategoriesUseCase.execute { [weak self] categories in
            DispatchQueue.main.async { [weak self] in
                self?.categories = categories.map { CategoryViewController.Model(title: $0.title) }
            }
        }
    }
}
