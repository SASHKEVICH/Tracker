import Foundation

protocol GetCategoriesUseCaseProtocol {
    func execute(_ completion: @escaping ([Category]) -> Void)
}
