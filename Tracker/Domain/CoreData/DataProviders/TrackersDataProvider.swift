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
    func didUpdate(update: TrackersStoreUpdate)
    func didRecievedTrackers()
}

protocol TrackersDataProviderCompletingProtocol {
    func completeTracker(with id: String, date: Date)
    func incompleteTracker(with id: String, date: Date)
}

protocol TrackersDataProviderFetchingProtocol {
    var numberOfSections: Int { get }
    func numberOfItemsInSection(_ section: Int) -> Int
    func fetchTrackers(currentWeekDay: WeekDay)
    func fetchTrackers(titleSearchString: String, currentWeekDay: WeekDay)
    func fetchCompletedRecords(date: Date) -> [TrackerRecordCoreData]
    func completedTimesCount(trackerId: String) -> Int
    func tracker(at indexPath: IndexPath) -> TrackerCoreData?
    func categoryTitle(at indexPath: IndexPath) -> String?
}

protocol TrackersDataProviderAddingProtocol {
    func add(tracker: Tracker, for categoryName: String) throws
    func deleteTracker(at indexPath: IndexPath) throws
}

typealias TrackersDataProviderProtocol =
    TrackersDataProviderCompletingProtocol
    & TrackersDataProviderFetchingProtocol
    & TrackersDataProviderAddingProtocol

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

	private let trackerFactory = TrackerFactory()

    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?

    private var currentWeekDay = Date().weekDay?.englishStringRepresentation
    
    private lazy var fetchedResultsController: NSFetchedResultsController = {
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        let sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TrackerCoreData.category.title), ascending: true),
            NSSortDescriptor(key: #keyPath(TrackerCoreData.title), ascending: true)
        ]
        request.sortDescriptors = sortDescriptors
        
        let predicate = NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(TrackerCoreData.weekDays), currentWeekDay ?? "")
        request.predicate = predicate
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
			sectionNameKeyPath: #keyPath(TrackerCoreData.category.title),
            cacheName: nil
		)
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

// MARK: - TrackersDataProviderFetchingProtocol
extension TrackersDataProvider: TrackersDataProviderFetchingProtocol {
    var numberOfSections: Int {
        let sectionsCount = fetchedResultsController.sections?.count ?? 0
        return sectionsCount
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func fetchTrackers(currentWeekDay: WeekDay) {
        fetchedResultsController.fetchRequest.predicate = NSPredicate(
            format: "%K CONTAINS[cd] %@",
            #keyPath(TrackerCoreData.weekDays), currentWeekDay.englishStringRepresentation)
        try? fetchedResultsController.performFetch()
    }
    
    func fetchTrackers(titleSearchString: String, currentWeekDay: WeekDay) {
        fetchedResultsController.fetchRequest.predicate = NSPredicate(
            format: "%K CONTAINS[cd] %@ AND %K CONTAINS[cd] %@",
            #keyPath(TrackerCoreData.title), titleSearchString,
            #keyPath(TrackerCoreData.weekDays), currentWeekDay.englishStringRepresentation)
        try? fetchedResultsController.performFetch()
    }
    
    func fetchCompletedRecords(date: Date) -> [TrackerRecordCoreData] {
        guard let onlyDate = date.onlyDate else { return [] }
        let trackerRecordsCoreData = trackerRecordDataStore.completedTrackers(for: onlyDate as NSDate)
        return trackerRecordsCoreData
    }
    
    func completedTimesCount(trackerId: String) -> Int {
        let count = try? trackerRecordDataStore.completedTimesCount(trackerId: trackerId)
        return count ?? 0
    }
    
    func tracker(at indexPath: IndexPath) -> TrackerCoreData? {
        fetchedResultsController.object(at: indexPath)
    }
    
    func categoryTitle(at indexPath: IndexPath) -> String? {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        return trackerCoreData.category.title
    }
}

// MARK: - TrackersDataProviderAddingProtocol
extension TrackersDataProvider: TrackersDataProviderAddingProtocol {
    func add(tracker: Tracker, for categoryName: String) throws {
		let trackerCoreData = trackerFactory.makeTrackerCoreData(from: tracker, context: context)
        
        guard let categoryCoreData = trackerCategoryDataStore.category(with: categoryName) else {
            throw TrackersDataProviderError.cannotFindCategory
        }
        
        try trackerDataStore.add(tracker: trackerCoreData, in: categoryCoreData)
    }
    
    func deleteTracker(at indexPath: IndexPath) throws {}
}

// MARK: - TrackersDataProviderCompletingProtocol
extension TrackersDataProvider: TrackersDataProviderCompletingProtocol {
    func completeTracker(with id: String, date: Date) {
        guard let date = date.onlyDate else { return }
        try? trackerRecordDataStore.completeTracker(with: id, date: date)
    }
    
    func incompleteTracker(with id: String, date: Date) {
        guard let date = date.onlyDate else { return }
        guard let record = trackerRecordDataStore.record(with: id, date: date as NSDate) else { return }
        try? trackerRecordDataStore.incompleteTracker(record)
    }
}

// MARK: - NSFetchedResultsControllerDelegate
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
        delegate?.didUpdate(update: TrackersStoreUpdate(
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
