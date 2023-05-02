//
//  TrackersDataProvider.swift
//  Tracker
//
//  Created by Александр Бекренев on 30.04.2023.
//

import UIKit
import CoreData

protocol TrackersDataProviderDelegate: AnyObject {
    func didUpdateCategories(insertedIndexes: IndexSet)
}

protocol TrackersDataProviderProtocol {
    var delegate: TrackersDataProviderDelegate? { get set }
    func add(category: TrackerCategory)
    func allCategories() -> [TrackerCategory]
    func object(at indexPath: IndexPath) -> TrackerCategory?
    func removeCategory(at indexPath: IndexPath)
    func fetchTrackers(for weekday: String)
}

final class TrackersDataProvider: NSObject {
    enum TrackersDataProviderError: Error {
        case failedToInitializeContext
        case failedToParseTracker
    }
    
    weak var delegate: TrackersDataProviderDelegate?
    
    private var context: NSManagedObjectContext
    
    private let trackerDataStore: TrackerDataStore
    private let trackerRecordDataStore: TrackerRecordDataStore
    private let trackerCategoryDataStore: TrackerCategoryDataStore
    
    private var insertedIndexes: IndexSet?
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        fetchRequest.predicate = nil
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    init(delegate: TrackersDataProviderDelegate? = nil) throws {
        do {
            let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
            let container = try appDelegate.getPersistentContainer()
            let viewContext = container.viewContext
            
            self.context = viewContext
            self.trackerDataStore = TrackerDataStore(context: context, container: container)
            self.trackerRecordDataStore = TrackerRecordDataStore(context: context, container: container)
            self.trackerCategoryDataStore = TrackerCategoryDataStore(context: context, container: container)
        } catch {
            throw error
        }
        
        self.delegate = delegate
    }
    
    private func performFetch(with predicate: NSPredicate?) {
        fetchedResultsController.fetchRequest.predicate = predicate
        try? fetchedResultsController.performFetch()
    }
}

extension TrackersDataProvider: TrackersDataProviderProtocol {
    func allCategories() -> [TrackerCategory] {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        let categoriesCoreData = try! context.fetch(fetchRequest)
        
        return try! categoriesCoreData.map {
            let trackers = try $0.trackers.allObjects.map { coreData throws in
                try decodeTracker(coreData)
            }
            return TrackerCategory(title: $0.title, trackers: trackers)
        }
    }
    
    func add(category: TrackerCategory) {
        try? trackerCategoryDataStore.add(newCategory: category)
    }
    
    func object(at indexPath: IndexPath) -> TrackerCategory? {
        let categoryCoreData = fetchedResultsController.object(at: indexPath)
        do {
            let trackers = try categoryCoreData.trackers.map { coreData throws in
                try decodeTracker(coreData)
            }
            return TrackerCategory(title: categoryCoreData.title, trackers: trackers)
        } catch {
            return TrackerCategory(title: categoryCoreData.title, trackers: [])
        }
    }
    
    func removeCategory(at indexPath: IndexPath) {
        let category = fetchedResultsController.object(at: indexPath)
        try? trackerCategoryDataStore.delete(category)
    }
    
    func fetchTrackers(for weekday: String) {
        let predicate = NSPredicate(
            format: "SUBQUERY(trackers, $t, $t.weekDays CONTAINS[c] %@).@count > 0", weekday)
        performFetch(with: predicate)
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackersDataProvider: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        insertedIndexes = IndexSet()
//        deletedIndexes = IndexSet()
    }

    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
//        delegate?.didUpdate(NotepadStoreUpdate(
//                insertedIndexes: insertedIndexes!,
//                deletedIndexes: deletedIndexes!
//            )
//        )
        delegate?.didUpdateCategories(insertedIndexes: insertedIndexes!)
        insertedIndexes = nil
//        deletedIndexes = nil
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes?.insert(indexPath.item)
            }
        default:
            break
        }
    }
}

// MARK: - Decoding trackers from CoreData
private extension TrackersDataProvider {
    func decodeTracker(_ coreData: Any) throws -> Tracker {
        guard
            let tracker = coreData as? TrackerCoreData,
            let id = UUID(uuidString: tracker.id),
            let type = TrackerType(rawValue: Int(tracker.type)),
            let color = UIColorMarshalling.deserilizeFrom(hex: tracker.colorHex)
        else { throw TrackersDataProviderError.failedToParseTracker }
        
        var schedule: [WeekDay]? = nil
        
        if let weekDays = tracker.weekDays {
            let splittedWeekDays = weekDays.split(separator: ",")
            schedule = splittedWeekDays.compactMap { String($0).weekDay }
        }
        
        return Tracker(
            id: id,
            type: type,
            title: tracker.title,
            color: color,
            emoji: tracker.emoji,
            schedule: schedule)
    }
}
