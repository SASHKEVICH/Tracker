import Foundation

final class CategoriesRepository: CategoriesRepositoryProtocol {

    private let trackersCategoryFactory: TrackersCategoryMapper
    private let categoriesDataProvider: TrackersCategoryDataProviderProtocol

    init(
        trackersCategoryFactory: TrackersCategoryMapper,
        categoriesDataProvider: TrackersCategoryDataProviderProtocol
    ) {
        self.trackersCategoryFactory = trackersCategoryFactory
        self.categoriesDataProvider = categoriesDataProvider
    }

    func getCategories() -> [Category] {
        let categories = self.categoriesDataProvider.categories
            .compactMap { trackersCategoryFactory.makeCategory(categoryCoreData: $0) }
            .compactMap { $0.toDomain() }
        return categories
    }
}
