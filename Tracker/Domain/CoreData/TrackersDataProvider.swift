//
//  TrackersDataProvider.swift
//  Tracker
//
//  Created by Александр Бекренев on 30.04.2023.
//

import UIKit
import CoreData

struct TrackersStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

protocol TrackersDataProviderDelegate: AnyObject {
    func didUpdate(_ update: TrackersStoreUpdate)
}

protocol TrackersDataProviderProtocol {
    var numberOfSections: Int { get }
    func numberOfItemsInSection(_ section: Int) -> Int
    func tracker(at indexPath: IndexPath) -> TrackerCoreData?
    func categoryTitle(at indexPath: IndexPath) -> String?
    func add(tracker: Tracker, for categoryName: String) throws
    func deleteTracker(at indexPath: IndexPath) throws
}

// MARK: - TrackersDataProvider
final class TrackersDataProvider: NSObject {
    enum TrackersDataProviderError: Error {
        case cannotFindCategory
    }
    
    weak var delegate: TrackersDataProviderDelegate?
    
    private let context: NSManagedObjectContext
    private let trackerDataStore: TrackerDataStore
    private let trackerCategoryDataStore: TrackerCategoryDataStore
    private let trackerRecordDataStore: TrackerRecordDataStore
    
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    
    private lazy var fetchedResultsController: NSFetchedResultsController = {
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        let sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TrackerCoreData.category.title), ascending: true),
            NSSortDescriptor(key: #keyPath(TrackerCoreData.title), ascending: true)
        ]
        request.sortDescriptors = sortDescriptors
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: #keyPath(TrackerCoreData.category.title),
            cacheName: nil)
        
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    init?(
        trackerDataStore: TrackerDataStore?,
        trackerCategoryDataStore: TrackerCategoryDataStore?,
        trackerRecordDataStore: TrackerRecordDataStore?
    ) {
        guard
            let trackerDataStore = trackerDataStore,
            let trackerCategoryDataStore = trackerCategoryDataStore,
            let trackerRecordDataStore = trackerRecordDataStore
        else { return nil }
        
        self.context = trackerDataStore.managedObjectContext
        self.trackerDataStore = trackerDataStore
        self.trackerCategoryDataStore = trackerCategoryDataStore
        self.trackerRecordDataStore = trackerRecordDataStore
    }
}

extension TrackersDataProvider: TrackersDataProviderProtocol {
    var numberOfSections: Int {
        let sectionsCount = fetchedResultsController.sections?.count ?? 0
        return sectionsCount
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tracker(at indexPath: IndexPath) -> TrackerCoreData? {
        fetchedResultsController.object(at: indexPath)
    }
    
    func add(tracker: Tracker, for categoryName: String) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.title = tracker.title
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.colorHex = UIColorMarshalling.serilizeToHex(color: tracker.color)
        trackerCoreData.id = tracker.id.uuidString
        trackerCoreData.type = Int16(tracker.type.rawValue)
        trackerCoreData.weekDays = "monday,wednesday,friday"
        
        guard let categoryCoreData = trackerCategoryDataStore.category(with: categoryName) else {
            throw TrackersDataProviderError.cannotFindCategory
        }
        
        try trackerDataStore.add(tracker: trackerCoreData, in: categoryCoreData)
    }
    
    func deleteTracker(at indexPath: IndexPath) throws {
        
    }
    
    func categoryTitle(at indexPath: IndexPath) -> String? {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        return trackerCoreData.category.title
    }
}

extension TrackersDataProvider: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }

    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        delegate?.didUpdate(TrackersStoreUpdate(
                insertedIndexes: insertedIndexes!,
                deletedIndexes: deletedIndexes!
            )
        )
        insertedIndexes = nil
        deletedIndexes = nil
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes?.insert(indexPath.item)
            }
        default:
            break
        }
    }
}
