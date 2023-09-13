import UIKit

protocol Presentable: AnyObject {
    func toPresent() -> UIViewController?
}

// MARK: - Presentable
extension UIViewController: Presentable {
    func toPresent() -> UIViewController? {
        return self
    }
}

protocol Routerable: Presentable {
    func present(_ module: Presentable?)
    func present(_ module: Presentable?, animated: Bool)

    func push(_ module: Presentable?)
    func push(_ module: Presentable?, hideBottomBar: Bool)
    func push(_ module: Presentable?, animated: Bool)
    func push(_ module: Presentable?, animated: Bool, completion: (() -> Void)?)
    func push(_ module: Presentable?, animated: Bool, hideBottomBar: Bool, completion: (() -> Void)?)

    func popModule()
    func popModule(animated: Bool)

    func dismissModule()
    func dismissModule(animated: Bool, completion: (() -> Void)?)

    func setRootModule(_ module: Presentable?)
    func setRootModule(_ module: Presentable?, hideBar: Bool)

    func popToRootModule(animated: Bool)
}

final class Router: Routerable {
    private weak var rootViewController: UINavigationController?
    private var completions: [UIViewController: () -> Void]

    init(rootViewController: UINavigationController) {
        self.rootViewController = rootViewController
        self.completions = [:]
    }

    func toPresent() -> UIViewController? {
        return self.rootViewController
    }

    func present(_ module: Presentable?) {
        self.present(module, animated: true)
    }

    func present(_ module: Presentable?, animated: Bool) {
        guard let controller = module?.toPresent() else { return }
        self.rootViewController?.present(controller, animated: animated)
    }

    func push(_ module: Presentable?) {
        self.push(module, animated: true)
    }

    func push(_ module: Presentable?, hideBottomBar: Bool) {
        self.push(module, animated: true, hideBottomBar: hideBottomBar, completion: nil)
    }

    func push(_ module: Presentable?, animated: Bool) {
        self.push(module, animated: animated, completion: nil)
    }

    func push(_ module: Presentable?, animated: Bool, completion: (() -> Void)?) {
        self.push(module, animated: animated, hideBottomBar: false, completion: completion)
    }

    func push(_ module: Presentable?, animated: Bool, hideBottomBar: Bool, completion: (() -> Void)?) {
        guard let controller = module?.toPresent(), (controller is UINavigationController == false) else {
            assertionFailure("Deprecated push UINavigationController.")
            return
        }

        if let completion {
            self.completions[controller] = completion
        }

        controller.hidesBottomBarWhenPushed = hideBottomBar
        self.rootViewController?.pushViewController(controller, animated: true)
    }

    func popModule() {
        self.popModule(animated: true)
    }

    func popModule(animated: Bool) {
        if let controller = self.rootViewController?.popViewController(animated: true) {
            self.runCompletion(for: controller)
        }
    }

    func dismissModule() {
        self.dismissModule(animated: true, completion: nil)
    }

    func dismissModule(animated: Bool, completion: (() -> Void)?) {
        self.rootViewController?.dismiss(animated: true, completion: completion)
    }

    func setRootModule(_ module: Presentable?) {
        self.setRootModule(module, hideBar: false)
    }

    func setRootModule(_ module: Presentable?, hideBar: Bool) {
        guard let controller = module?.toPresent() else { return }
        self.rootViewController?.setViewControllers([controller], animated: false)
        self.rootViewController?.isNavigationBarHidden = hideBar
    }

    func popToRootModule(animated: Bool) {
        guard let controllers = self.rootViewController?.popToRootViewController(animated: animated) else {
            return
        }
        controllers.forEach { controller in self.runCompletion(for: controller) }
    }

    private func runCompletion(for controller: UIViewController) {
        guard let completion = self.completions[controller] else { return }
        completion()
        self.completions.removeValue(forKey: controller)
    }
}
