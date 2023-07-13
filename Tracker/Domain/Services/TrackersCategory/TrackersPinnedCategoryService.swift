//
//  TrackersPinnedCategoryService.swift
//  Tracker
//
//  Created by Александр Бекренев on 13.07.2023.
//

import UIKit

protocol TrackersPinnedCategoryServiceProtocol {
	func checkPinnedCategory()
}

struct TrackersPinnedCategoryService {
	private let userDefaults = UserDefaults.standard
	private let key = "pinnedCategoryId"

	private let trackersCategoryDataStore: TrackersCategoryDataStore
	private let trackersCategoryFactory: TrackersCategoryFactory

	init?(trackersCategoryFactory: TrackersCategoryFactory) {
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
			  let trackersCategoryDataStore = appDelegate.trackersCategoryDataStore
		else {
			assertionFailure("Cannot activate data stores")
			return nil
		}

		self.trackersCategoryDataStore = trackersCategoryDataStore
		self.trackersCategoryFactory = trackersCategoryFactory
	}
}

// MARK: - TrackersCategoryPinnedServiceProtocol
extension TrackersPinnedCategoryService: TrackersPinnedCategoryServiceProtocol {
	func checkPinnedCategory() {
		if let _ = self.pinnedCategoryId {
			self.checkPinnedCategoryTitleAccordingToMainLanguage()
		} else {
			self.createPinnedCategory()
		}
	}
}

private extension TrackersPinnedCategoryService {
	var pinnedCategoryId: UUID? {
		guard let string = self.userDefaults.string(forKey: self.key),
			  let id = UUID(uuidString: string)
		else { return nil }
		return id
	}

	func storePinnedCategory(with id: UUID) {
		self.userDefaults.set(id.uuidString, forKey: self.key)
	}

	func createPinnedCategory() {
		let title = R.string.localizable.trackerCategoryPinnedCategoryTitle()
		let id = UUID()
		let category = TrackerCategory(id: id, title: title, trackers: [])
		let categoryCoreData = trackersCategoryFactory.makeCategoryCoreData(
			from: category,
			context: self.trackersCategoryDataStore.managedObjectContext
		)

		guard let _ = try? self.trackersCategoryDataStore.add(category: categoryCoreData) else {
			assertionFailure("Cannot create pinned category")
			return
		}

		self.storePinnedCategory(with: id)
	}

	func checkPinnedCategoryTitleAccordingToMainLanguage() {
		guard let id = self.pinnedCategoryId,
			  let category = self.trackersCategoryDataStore.category(with: id.uuidString)
		else { return }

		let actualLanguageTitle = R.string.localizable.trackerCategoryPinnedCategoryTitle()
		if category.title != actualLanguageTitle {
			self.trackersCategoryDataStore.rename(category: category, newTitle: actualLanguageTitle)
		}
	}
}

