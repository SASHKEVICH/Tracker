//
//  TrackersPinnedCategoryService.swift
//  Tracker
//
//  Created by Александр Бекренев on 13.07.2023.
//

import Foundation

protocol TrackersPinnedCategoryServiceProtocol {
    var pinnedCategoryId: UUID? { get }
    func checkPinnedCategory()
}

final class TrackersPinnedCategoryService {
    private let userDefaults = UserDefaults.standard
    private let key = "pinnedCategoryId"

    private let trackersCategoryDataStore: TrackersCategoryDataStore
    private let trackersCategoryFactory: TrackersCategoryFactory

    init?(trackersCategoryFactory: TrackersCategoryFactory, trackersCategoryDataStore: TrackersCategoryDataStore) {
        self.trackersCategoryDataStore = trackersCategoryDataStore
        self.trackersCategoryFactory = trackersCategoryFactory
    }
}

// MARK: - TrackersCategoryPinnedServiceProtocol

extension TrackersPinnedCategoryService: TrackersPinnedCategoryServiceProtocol {
    var pinnedCategoryId: UUID? {
        guard let string = self.userDefaults.string(forKey: self.key),
              let id = UUID(uuidString: string)
        else { return nil }
        return id
    }

    func checkPinnedCategory() {
        if let _ = self.pinnedCategoryId {
            self.checkPinnedCategoryTitleAccordingToMainLanguage()
        } else {
            self.createPinnedCategory()
        }
    }
}

private extension TrackersPinnedCategoryService {
    func storePinnedCategory(with id: UUID) {
        self.userDefaults.set(id.uuidString, forKey: self.key)
    }

    func createPinnedCategory() {
        let title = R.string.localizable.trackerCategoryPinnedCategoryTitle()
        let category = trackersCategoryFactory.makeCategory(title: title, isPinning: true)
        let categoryCoreData = trackersCategoryFactory.makeCategoryCoreData(
            from: category,
            context: self.trackersCategoryDataStore.managedObjectContext
        )

        guard let _ = try? self.trackersCategoryDataStore.add(category: categoryCoreData) else {
            assertionFailure("Cannot create pinned category")
            return
        }

        self.storePinnedCategory(with: category.id)
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
