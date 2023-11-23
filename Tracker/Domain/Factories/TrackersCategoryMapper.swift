import CoreData
import Foundation

public struct TrackersCategoryMapper {
    private let trackersFactory: TrackersFactory

    public init(trackersFactory: TrackersFactory) {
        self.trackersFactory = trackersFactory
    }

    public func makeCategory(title: String, isPinning: Bool) -> Category {
        Category(id: UUID(), title: title, trackers: [], isPinning: isPinning)
    }

    func makeCategory(id: UUID, title: String, isPinning: Bool) -> Category {
        Category(id: id, title: title, trackers: [], isPinning: isPinning)
    }

    func makeCategory(categoryCoreData category: TrackerCategoryCoreData) -> CategoryDTO? {
        guard let id = UUID(uuidString: category.id) else {
            assertionFailure("Could not parse uuid from string")
            return nil
        }
        let trackers = category.trackers
            .compactMap { $0 as? TrackerCoreData }
            .compactMap { trackersFactory.makeTracker(from: $0) }
        return CategoryDTO(id: id, title: category.title, trackers: trackers, isPinning: category.isPinning)
    }

    func makeCategoryCoreData(
        from category: Category,
        context: NSManagedObjectContext
    ) -> TrackerCategoryCoreData {
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.id = category.id.uuidString
        categoryCoreData.title = category.title
        categoryCoreData.isPinning = category.isPinning
        categoryCoreData.trackers = NSSet(array: category.trackers)
        return categoryCoreData
    }
}
