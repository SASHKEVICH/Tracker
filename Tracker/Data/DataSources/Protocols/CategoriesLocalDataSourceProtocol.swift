import Foundation
import RealmSwift

protocol CategoriesLocalDataSourceProtocol {
    func fetchCategories(_ completion: @escaping (Results<CategoryObject>?) -> Void)
}
