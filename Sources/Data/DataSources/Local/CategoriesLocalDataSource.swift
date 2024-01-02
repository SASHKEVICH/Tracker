import Foundation
import RealmSwift

final class CategoriesLocalDataSource: CategoriesLocalDataSourceProtocol {

    private let realmProvider = RealmProvider()

    private let categoriesQueue = DispatchQueue(label: "ru.yandex.tracker.categories-queue", qos: .userInitiated)

    func fetchCategories(_ completion: @escaping (Results<CategoryObject>?) -> Void) {
        self.categoriesQueue.async { [weak self] in
            let categories = self?.realmProvider.realm()?.objects(CategoryObject.self)
            completion(categories)
        }
    }
}
