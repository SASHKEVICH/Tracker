import UIKit

final class OnboardingPageControllerDelegate: NSObject, UIPageViewControllerDelegate {

    // MARK: - Private Properties

    private let viewModel: OnboardingViewModelDelegateProtocol
    private let pages: [UIViewController]

    // MARK: - Init

    init(
        viewModel: OnboardingViewModelDelegateProtocol,
        pages: [UIViewController]
    ) {
        self.viewModel = viewModel
        self.pages = pages
    }

    // MARK: - Methods

    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating _: Bool,
        previousViewControllers _: [UIViewController],
        transitionCompleted _: Bool
    ) {
        guard let currentViewController = pageViewController.viewControllers?.first,
              let currentIndex = self.pages.firstIndex(of: currentViewController)
        else { return }

        self.viewModel.setCurrentPage(index: currentIndex)
    }
}
