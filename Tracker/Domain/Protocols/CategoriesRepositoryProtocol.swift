import Foundation

protocol CategoriesRepositoryProtocol {
    func getCategories(_ completion: @escaping ([Category]) -> Void)
}
