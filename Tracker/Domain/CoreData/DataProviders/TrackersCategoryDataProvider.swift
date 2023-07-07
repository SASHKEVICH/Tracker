//
//  TrackersCategoryDataProvider.swift
//  Tracker
//
//  Created by Александр Бекренев on 07.07.2023.
//

import Foundation
import CoreData

struct TrackersCategoryStoreUpdate {
	let insertedIndexes: IndexSet
	let deletedIndexes: IndexSet
}

protocol TrackersCategoryDataProviderDelegate: AnyObject {
	func storeDidUpdate()
}

protocol TrackersCategoryDataProviderProtocol {
	var delegate: TrackersCategoryDataProviderDelegate? { get set }
	var categories: [TrackerCategoryCoreData] { get }
	func numberOfItemsInSection(_ section: Int) -> Int
}

final class TrackersCategoryDataProvider: NSObject {
	weak var delegate: TrackersCategoryDataProviderDelegate?

	private let context: NSManagedObjectContext

	private var insertedIndexes: IndexSet?
	private var deletedIndexes: IndexSet?

	private lazy var fetchedResultsController: NSFetchedResultsController = {
		let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
		let sortDescriptors = [NSSortDescriptor(key: #keyPath(TrackerCategoryCoreData.title), ascending: true)]
		request.sortDescriptors = sortDescriptors
		request.predicate = nil

		let fetchedResultsController = NSFetchedResultsController(
			fetchRequest: request,
			managedObjectContext: context,
			sectionNameKeyPath: nil,
			cacheName: nil
		)
		fetchedResultsController.delegate = self

		try? fetchedResultsController.performFetch()
		return fetchedResultsController
	}()

	init(context: NSManagedObjectContext) {
		self.context = context
	}
}

// MARK: - TrackersCategoryDataProviderProtocol
extension TrackersCategoryDataProvider: TrackersCategoryDataProviderProtocol {
	var categories: [TrackerCategoryCoreData] {
		self.fetchedResultsController.fetchedObjects ?? []
	}

	func numberOfItemsInSection(_ section: Int) -> Int {
		self.fetchedResultsController.sections?[section].numberOfObjects ?? 0
	}
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackersCategoryDataProvider: NSFetchedResultsControllerDelegate {
	func controllerWillChangeContent(
		_ controller: NSFetchedResultsController<NSFetchRequestResult>
	) {
		self.insertedIndexes = IndexSet()
		self.deletedIndexes = IndexSet()
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
				self.deletedIndexes?.insert(indexPath.item)
			}
		case .insert:
			if let indexPath = newIndexPath {
				self.insertedIndexes?.insert(indexPath.item)
			}
		default:
			break
		}
	}
}
