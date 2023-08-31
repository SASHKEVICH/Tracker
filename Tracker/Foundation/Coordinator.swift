import UIKit

protocol Coordinator: AnyObject {
    var finishDelegate: CoordinatorFinishDelegate? { get set }
    var navigationController: UINavigationController { get set }
    var childCoordinators: [Coordinator] { get set }
    var type: CoordinatorType { get }
    func start()
    func finish()
}

extension Coordinator {
    func finish() {
        childCoordinators.removeAll()
        finishDelegate?.coordinatorFinishDelegate(childCoordinator: self, didFinish: true)
    }
}

protocol CoordinatorFinishDelegate: AnyObject {
    func coordinatorFinishDelegate(childCoordinator: Coordinator, didFinish: Bool)
}

enum CoordinatorType {
    case app
    case onboarding
    case tab
}
