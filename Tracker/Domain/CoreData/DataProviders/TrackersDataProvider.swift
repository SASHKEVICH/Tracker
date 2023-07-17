//
//  TrackersDataProvider.swift
//  Tracker
//
//  Created by Александр Бекренев on 30.04.2023.
//

import Foundation
import CoreData

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
	func fetchCompletedTrackers(for weekDay: WeekDay)
	func fetchIncompletedTrackers(for weekDay: WeekDay)
    func fetchTrackers(currentWeekDay: WeekDay)
    func fetchTrackers(titleSearchString: String, currentWeekDay: WeekDay)
    func tracker(at indexPath: IndexPath) -> TrackerCoreData?
    func categoryTitle(at indexPath: IndexPath) -> String?
	func eraseOperations()
}

// MARK: - TrackersDataProvider
final class TrackersDataProvider: NSObject {
	weak var delegate: TrackersDataProviderDelegate?

	private let context: NSManagedObjectContext

	private var blockOperations: [BlockOperation] = []
	private var currentWeekDay = Date().weekDay

	private lazy var fetchedResultsController: NSFetchedResultsController = {
		let request = TrackerCoreData.fetchRequest()
		let sortDescriptors = [
			NSSortDescriptor(key: #keyPath(TrackerCoreData.category.isPinning), ascending: false),
			NSSortDescriptor(key: #keyPath(TrackerCoreData.category.title), ascending: true),
			NSSortDescriptor(key: #keyPath(TrackerCoreData.title), ascending: true)
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

	init(context: NSManagedObjectContext) {
		self.context = context
    }

	deinit {
		self.blockOperations.removeAll(keepingCapacity: false)
	}
}

// MARK: - TrackersDataProviderProtocol
extension TrackersDataProvider: TrackersDataProviderProtocol {
    var numberOfSections: Int {
		self.fetchedResultsController.sections?.count ?? 0
    }

	var trackers: [TrackerCoreData] {
		self.fetchedResultsController.fetchedObjects ?? []
	}
    
    func numberOfItemsInSection(_ section: Int) -> Int {
		self.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

	func fetchTrackersForToday() {
		guard let currentWeekDay = self.currentWeekDay else { return }
		self.fetchTrackers(currentWeekDay: currentWeekDay)
	}
    
    func fetchTrackers(currentWeekDay: WeekDay) {
		let predicate = NSPredicate(
            format: "%K CONTAINS[cd] %@",
            #keyPath(TrackerCoreData.weekDays), currentWeekDay.englishStringRepresentation
		)
		self.performFetch(with: predicate)
    }
    
    func fetchTrackers(titleSearchString: String, currentWeekDay: WeekDay) {
		let predicate = NSPredicate(
            format: "%K CONTAINS[cd] %@ AND %K CONTAINS[cd] %@",
            #keyPath(TrackerCoreData.title), titleSearchString,
            #keyPath(TrackerCoreData.weekDays), currentWeekDay.englishStringRepresentation
		)
		self.performFetch(with: predicate)
    }

	func fetchCompletedTrackers(for weekDay: WeekDay) {
		let predicate = NSPredicate(
			format: "%K CONTAINS[cd] %@ AND %K.@count != 0",
			#keyPath(TrackerCoreData.weekDays), weekDay.englishStringRepresentation,
			#keyPath(TrackerCoreData.records)
		)
		self.performFetch(with: predicate)
	}

	func fetchIncompletedTrackers(for weekDay: WeekDay) {
		let predicate = NSPredicate(
			format: "%K CONTAINS[cd] %@ AND %K.@count == 0",
			#keyPath(TrackerCoreData.weekDays), weekDay.englishStringRepresentation,
			#keyPath(TrackerCoreData.records)
		)
		self.performFetch(with: predicate)
	}
    
    func tracker(at indexPath: IndexPath) -> TrackerCoreData? {
		self.fetchedResultsController.object(at: indexPath)
    }
    
    func categoryTitle(at indexPath: IndexPath) -> String? {
		let trackerCoreData = self.fetchedResultsController.object(at: indexPath)
        return trackerCoreData.category.title
    }

	func eraseOperations() {
		self.blockOperations.removeAll(keepingCapacity: false)
	}
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackersDataProvider: NSFetchedResultsControllerDelegate {
	func controller(
		_ controller: NSFetchedResultsController<NSFetchRequestResult>,
		didChange anObject: Any,
		at indexPath: IndexPath?,
		for type: NSFetchedResultsChangeType,
		newIndexPath: IndexPath?
	) {
		var operation = BlockOperation()
		switch type {
		case .insert:
			guard let newIndexPath = newIndexPath else { return }
			operation = BlockOperation { self.delegate?.insertItems(at: [newIndexPath]) }
		case .delete:
			guard let indexPath = indexPath else { return }
			operation = BlockOperation { self.delegate?.deleteItems(at: [indexPath]) }
		case .move:
			guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
			operation = BlockOperation { self.delegate?.moveItems(at: indexPath, to: newIndexPath) }
		case .update:
			guard let indexPath = indexPath else { return }
			operation = BlockOperation { self.delegate?.reloadItems(at: [indexPath]) }
		@unknown default:
			assertionFailure("some fetched results controller error")
			break
		}

		self.blockOperations.append(operation)
	}

	func controller(
		_ controller: NSFetchedResultsController<NSFetchRequestResult>,
		didChange sectionInfo: NSFetchedResultsSectionInfo,
		atSectionIndex sectionIndex: Int,
		for type: NSFetchedResultsChangeType
	) {
		let indexSet = IndexSet(integer: sectionIndex)

		var operation = BlockOperation()
		switch type {
		case .insert:
			operation = BlockOperation { self.delegate?.insertSections(at: indexSet) }
		case .delete:
			operation = BlockOperation { self.delegate?.deleteSections(at: indexSet) }
		case .update:
			operation = BlockOperation { self.delegate?.reloadSections(at: indexSet) }
		default:
			assertionFailure("some fetchedresultscontroller error")
			break
		}

		self.blockOperations.append(operation)
	}

	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		self.delegate?.didChangeContent(operations: self.blockOperations)
	}
}

private extension TrackersDataProvider {
	func performFetch(with predicate: NSPredicate) {
		self.fetchedResultsController.fetchRequest.predicate = predicate
		try? self.fetchedResultsController.performFetch()
		self.delegate?.fetchDidPerformed()
	}
}
