//
//  TrackersDataProvider.swift
//  Tracker
//
//  Created by Александр Бекренев on 30.04.2023.
//

import CoreData
import Foundation

public typealias TrackersCollectionCellIndices = [IndexPath]

public protocol TrackersDataProviderDelegate: AnyObject {
    func fetchDidPerformed()

    func insertItems(at: TrackersCollectionCellIndices)
    func deleteItems(at: TrackersCollectionCellIndices)
    func moveItems(at: IndexPath, to: IndexPath)
    func reloadItems(at: TrackersCollectionCellIndices)
    func didChangeContent(operations: [BlockOperation])

    func insertSections(at: IndexSet)
    func deleteSections(at: IndexSet)
    func reloadSections(at: IndexSet)
}

protocol TrackersDataProviderProtocol {
    var delegate: TrackersDataProviderDelegate? { get set }
    var numberOfSections: Int { get }
    var trackers: [TrackerCoreData] { get }
    func numberOfItemsInSection(_ section: Int) -> Int
    func fetchTrackersForToday()
    func fetchCompletedTrackers(for date: Date)
    func fetchIncompletedTrackers(for date: Date)
    func fetchTrackers(currentWeekDay: WeekDay)
    func fetchTrackers(titleSearchString: String, currentWeekDay: WeekDay)
    func tracker(at indexPath: IndexPath) -> TrackerCoreData?
    func categoryTitle(at indexPath: IndexPath) -> String?
    func eraseOperations()
}

// MARK: - TrackersDataProvider

final class TrackersDataProvider: NSObject {
    weak var delegate: TrackersDataProviderDelegate? {
        didSet {
            blockOperationFactory.delegate = delegate
        }
    }

    private let context: NSManagedObjectContext

    private var blockOperations: [BlockOperation] = []
    private var blockOperationFactory: BlockOperationFactoryProtocol

    private var currentWeekDay = Date().weekDay
    private var currentDay = Date()

    private lazy var fetchedResultsController: NSFetchedResultsController = {
        let request = TrackerCoreData.fetchRequest()
        let sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TrackerCoreData.category.isPinning), ascending: false),
            NSSortDescriptor(key: #keyPath(TrackerCoreData.category.title), ascending: true),
            NSSortDescriptor(key: #keyPath(TrackerCoreData.title), ascending: true),
        ]
        request.sortDescriptors = sortDescriptors

        let predicate = NSPredicate(
            format: "%K CONTAINS[cd] %@",
            #keyPath(TrackerCoreData.weekDays), self.currentWeekDay?.englishStringRepresentation ?? ""
        )
        request.predicate = predicate

        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: #keyPath(TrackerCoreData.category.id),
            cacheName: nil
        )
        fetchedResultsController.delegate = self

        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()

    init(context: NSManagedObjectContext, blockOperationFactory: BlockOperationFactoryProtocol) {
        self.context = context
        self.blockOperationFactory = blockOperationFactory
    }

    deinit {
        self.blockOperations.removeAll(keepingCapacity: false)
    }
}

// MARK: - TrackersDataProviderProtocol

extension TrackersDataProvider: TrackersDataProviderProtocol {
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }

    var trackers: [TrackerCoreData] {
        fetchedResultsController.fetchedObjects ?? []
    }

    func numberOfItemsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func fetchTrackersForToday() {
        guard let currentWeekDay = currentWeekDay else { return }
        fetchTrackers(currentWeekDay: currentWeekDay)
    }

    func fetchTrackers(currentWeekDay: WeekDay) {
        let predicate = NSPredicate(
            format: "%K CONTAINS[cd] %@",
            #keyPath(TrackerCoreData.weekDays), currentWeekDay.englishStringRepresentation
        )
        performFetch(with: predicate)
    }

    func fetchTrackers(titleSearchString: String, currentWeekDay: WeekDay) {
        let predicate = NSPredicate(
            format: "%K CONTAINS[cd] %@ AND %K CONTAINS[cd] %@",
            #keyPath(TrackerCoreData.title), titleSearchString,
            #keyPath(TrackerCoreData.weekDays), currentWeekDay.englishStringRepresentation
        )
        performFetch(with: predicate)
    }

    func fetchCompletedTrackers(for date: Date) {
        guard let date = date.withoutTime,
              let weekDay = date.weekDay
        else { return }
        let predicate = NSPredicate(
            format: "%K CONTAINS[cd] %@ AND %K.@count > 0 AND SUBQUERY(records, $record, $record.date == %@).@count > 0",
            #keyPath(TrackerCoreData.weekDays), weekDay.englishStringRepresentation,
            #keyPath(TrackerCoreData.records), date as NSDate
        )
        performFetch(with: predicate)
    }

    func fetchIncompletedTrackers(for date: Date) {
        guard let date = date.withoutTime,
              let weekDay = date.weekDay
        else { return }
        let predicate = NSPredicate(
            format: "%K CONTAINS[cd] %@ AND %K.@count == 0 AND SUBQUERY(records, $record, $record.date == %@).@count == 0",
            #keyPath(TrackerCoreData.weekDays), weekDay.englishStringRepresentation,
            #keyPath(TrackerCoreData.records), date as NSDate
        )
        performFetch(with: predicate)
    }

    func tracker(at indexPath: IndexPath) -> TrackerCoreData? {
        fetchedResultsController.object(at: indexPath)
    }

    func categoryTitle(at indexPath: IndexPath) -> String? {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        return trackerCoreData.category.title
    }

    func eraseOperations() {
        blockOperations.removeAll(keepingCapacity: false)
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackersDataProvider: NSFetchedResultsControllerDelegate {
    func controller(
        _: NSFetchedResultsController<NSFetchRequestResult>,
        didChange _: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        if let operation = blockOperationFactory.makeObjectOperation(at: indexPath, to: newIndexPath, for: type) {
            blockOperations.append(operation)
        }
    }

    func controller(
        _: NSFetchedResultsController<NSFetchRequestResult>,
        didChange _: NSFetchedResultsSectionInfo,
        atSectionIndex sectionIndex: Int,
        for type: NSFetchedResultsChangeType
    ) {
        if let operation = blockOperationFactory.makeSectionOperation(sectionIndex: sectionIndex, for: type) {
            blockOperations.append(operation)
        }
    }

    func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didChangeContent(operations: blockOperations)
    }
}

private extension TrackersDataProvider {
    func performFetch(with predicate: NSPredicate) {
        fetchedResultsController.fetchRequest.predicate = predicate
        try? fetchedResultsController.performFetch()
        delegate?.fetchDidPerformed()
    }
}
