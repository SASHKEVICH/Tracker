import Foundation

final class CategoriesRepository: CategoriesRepositoryProtocol {

    private let localDataSource: CategoriesLocalDataSourceProtocol
    private let trackersCategoryMapper: TrackersCategoryMapper

    init(
        localDataSource: CategoriesLocalDataSourceProtocol,
        trackersCategoryMapper: TrackersCategoryMapper
    ) {
        self.localDataSource = localDataSource
        self.trackersCategoryMapper = trackersCategoryMapper
    }

    func getCategories(_ completion: @escaping ([Category]) -> Void) {
        self.localDataSource.fetchCategories { localCategories in
            guard let localCategories = localCategories else {
                completion([])
                return
            }

            let categories = Array(localCategories.map { $0.toDomain() })
            completion(categories)
        }
    }
}
