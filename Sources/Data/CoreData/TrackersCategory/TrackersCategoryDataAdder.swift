import CoreData
import Foundation

protocol TrackersCategoryDataAdderProtocol {
    func add(category: Category) throws
}

struct TrackersCategoryDataAdder {
    private let context: NSManagedObjectContext
    private let trackersCategoryDataStore: TrackersCategoryDataStore
    private let trackersCategoryFactory: TrackersCategoryMapper

    init(
        trackersCategoryDataStore: TrackersCategoryDataStore,
        trackersCategoryFactory: TrackersCategoryMapper
    ) {
        self.trackersCategoryDataStore = trackersCategoryDataStore
        self.trackersCategoryFactory = trackersCategoryFactory
        self.context = trackersCategoryDataStore.managedObjectContext
    }
}

// MARK: - TrackersCategoryDataAdderProtocol

extension TrackersCategoryDataAdder: TrackersCategoryDataAdderProtocol {
    func add(category: Category) throws {
        let categoryCoreData = self.trackersCategoryFactory.makeCategoryCoreData(from: category, context: self.context)
        try trackersCategoryDataStore.add(category: categoryCoreData)
    }
}
