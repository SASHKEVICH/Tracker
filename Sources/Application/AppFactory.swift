import Foundation

final class AppFactory {

    private lazy var trackersFactory = TrackersFactory()

    private lazy var trackerCategoryMapper = TrackersCategoryMapper(trackersFactory: trackersFactory)

    private lazy var categoriesRepository: CategoriesRepository = {
        let localDataSource = CategoriesLocalDataSource()
        let mapper = TrackersCategoryMapper(trackersFactory: trackersFactory)

        return CategoriesRepository(localDataSource: localDataSource, trackersCategoryMapper: mapper)
    }()
}

// MARK: - First Launch

extension AppFactory {
    func makeCheckFirstLaunchUseCase() -> CheckFirstLaunchUseCaseProtocol {
        CheckFirstLaunchUseCase()
    }
}

// MARK: - Categories

extension AppFactory {
    func makeGetCategoriesUseCase() -> GetCategoriesUseCaseProtocol {
        return GetCategoriesUseCase(
            categoriesRepository: categoriesRepository
        )
    }
}
