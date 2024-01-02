import UIKit

protocol OnboardingPageControllerDataSource: UIPageViewControllerDataSource {
    var pagesCount: Int { get }
    var currentPage: Int { get }
    var firstViewController: UIViewController? { get }
}

final class OnboardingPageControllerDataSourceImpl: NSObject, OnboardingPageControllerDataSource {

    // MARK: - Internal Properties

    var pagesCount: Int {
        self.pages.count
    }

    var currentPage: Int {
        return 0
    }

    var firstViewController: UIViewController? {
        self.pages.first
    }

    // MARK: - Private Properties

    private let pages: [UIViewController]

    // MARK: - Init

    init(pages: [UIViewController]) {
        self.pages = pages
    }

    // MARK: - Methods

    func pageViewController(
        _: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let viewControllerIndex = self.pages.firstIndex(of: viewController) else { return nil }

        let previousIndex = viewControllerIndex - 1

        guard previousIndex >= 0 else { return self.pages.last }

        return self.pages[previousIndex]
    }

    func pageViewController(
        _: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let viewControllerIndex = self.pages.firstIndex(of: viewController) else { return nil }

        let nextIndex = viewControllerIndex + 1

        guard nextIndex < self.pages.count else { return self.pages.first }

        return self.pages[nextIndex]
    }
}
