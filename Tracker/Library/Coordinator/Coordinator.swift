import UIKit

protocol Coordinator: AnyObject {
    func start()
}

class BaseCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []

    func start() {}

    func addDependency(_ coordinator: Coordinator) {
        guard !self.childCoordinators.contains(where: { $0 === coordinator }) else { return }
        self.childCoordinators.append(coordinator)
    }

    func removeDependency(_ coordinator: Coordinator?) {
        guard self.childCoordinators.isEmpty, let coordinator else { return }

        if let coordinator = coordinator as? BaseCoordinator, !coordinator.childCoordinators.isEmpty {
            coordinator.childCoordinators
                .filter({ $0 !== coordinator })
                .forEach({ coordinator.removeDependency($0) })
        }

        for (index, element) in self.childCoordinators.enumerated() where element === coordinator {
            self.childCoordinators.remove(at: index)
            break
        }
    }
}
