import UIKit

final class OnboardingPageViewController: UIPageViewController {
    var firstViewController: UIViewController? { self.pages.first }
    var pagesCount: Int { self.pages.count }

    var onCurrentPageChanged: Action<Int>?

    private var pages: [UIViewController] = []

    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        self.dataSource = self
    }

    func set(pages: [UIViewController]) {
        self.pages = pages

        if let controller = pages.first {
            self.setViewControllers([controller], direction: .forward, animated: true)
        }
    }
}

// MARK: - UIPageViewControllerDelegate
extension OnboardingPageViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating _: Bool,
        previousViewControllers _: [UIViewController],
        transitionCompleted _: Bool
    ) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController)
        {
            self.onCurrentPageChanged?(currentIndex)
        }
    }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingPageViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let controllerIndex = self.pages.firstIndex(of: viewController) else { return nil }

        let previousIndex = controllerIndex - 1

        if previousIndex >= 0 {
            return self.pages[previousIndex]
        } else {
            return self.pages.last
        }
    }

    func pageViewController(
        _: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let controllerIndex = pages.firstIndex(of: viewController) else { return nil }

        let nextIndex = controllerIndex + 1

        if nextIndex < self.pages.count {
            return self.pages[nextIndex]
        } else {
            return self.pages.first
        }
    }
}
