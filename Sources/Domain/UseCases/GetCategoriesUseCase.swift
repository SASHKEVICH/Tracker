import Foundation

final class GetCategoriesUseCase: GetCategoriesUseCaseProtocol {

    private let categoriesRepository: CategoriesRepositoryProtocol

    init(categoriesRepository: CategoriesRepositoryProtocol) {
        self.categoriesRepository = categoriesRepository
    }

    func execute(_ completion: @escaping ([Category]) -> Void) {
        self.categoriesRepository.getCategories { categories in
            completion(categories)
        }
    }
}
