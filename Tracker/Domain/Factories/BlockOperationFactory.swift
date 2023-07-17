//
//  BlockOperationFactory.swift
//  Tracker
//
//  Created by Александр Бекренев on 17.07.2023.
//

import Foundation
import CoreData

protocol BlockOperationFactoryProtocol {
	var delegate: TrackersDataProviderDelegate? { get set }
	func makeObjectOperation(
		at indexPath: IndexPath,
		to newIndexPath: IndexPath,
		for type: NSFetchedResultsChangeType
	) -> BlockOperation?

	func makeSectionOperation(
		sectionIndex: Int,
		for type: NSFetchedResultsChangeType
	) -> BlockOperation?
}

final class BlockOperationFactory {
	var delegate: TrackersDataProviderDelegate?
}

// MARK: - BlockOperationFactoryProtocol
extension BlockOperationFactory: BlockOperationFactoryProtocol {
	func makeObjectOperation(
		at indexPath: IndexPath,
		to newIndexPath: IndexPath,
		for type: NSFetchedResultsChangeType
	) -> BlockOperation? {
		switch type {
		case .insert:
			return BlockOperation { self.delegate?.insertItems(at: [newIndexPath]) }
		case .delete:
			return BlockOperation { self.delegate?.deleteItems(at: [indexPath]) }
		case .move:
			return BlockOperation { self.delegate?.moveItems(at: indexPath, to: newIndexPath) }
		case .update:
			return BlockOperation { self.delegate?.reloadItems(at: [indexPath]) }
		@unknown default:
			assertionFailure("some fetched results controller error")
			return nil
		}
	}

	func makeSectionOperation(
		sectionIndex: Int,
		for type: NSFetchedResultsChangeType
	) -> BlockOperation? {
		let indexSet = IndexSet(integer: sectionIndex)
		switch type {
		case .insert:
			return BlockOperation { self.delegate?.insertSections(at: indexSet) }
		case .delete:
			return BlockOperation { self.delegate?.deleteSections(at: indexSet) }
		case .update:
			return BlockOperation { self.delegate?.reloadSections(at: indexSet) }
		default:
			assertionFailure("some fetchedresultscontroller error")
			return nil
		}
	}
}
