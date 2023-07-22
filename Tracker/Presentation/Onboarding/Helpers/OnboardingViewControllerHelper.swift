//
//  OnboardingViewControllerHelper.swift
//  Tracker
//
//  Created by Александр Бекренев on 24.05.2023.
//

import UIKit

protocol OnboardingViewControllerHelperProtocol: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    var presenter: OnboardingViewPresenterProtocol? { get set }
    var firstViewController: UIViewController? { get }
    var pagesCount: Int { get }
}

final class OnboardingViewControllerHelper: NSObject {
    weak var presenter: OnboardingViewPresenterProtocol?

    private let pages: [UIViewController] = {
        let firstPage = OnboardingPageViewController()
        let secondPage = OnboardingPageViewController()

        firstPage.image = .Onboarding.first
        secondPage.image = .Onboarding.second

        firstPage.onboardingText = R.string.localizable.onboardingPageLabelFirst()
        secondPage.onboardingText = R.string.localizable.onboardingPageLabelSecond()

        return [firstPage, secondPage]
    }()
}

// MARK: - OnboardingViewControllerHelperProtocol

extension OnboardingViewControllerHelper: OnboardingViewControllerHelperProtocol {
    var firstViewController: UIViewController? {
        pages.first
    }

    var pagesCount: Int {
        pages.count
    }

    // UIPageViewControllerDelegate
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating _: Bool,
        previousViewControllers _: [UIViewController],
        transitionCompleted _: Bool
    ) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController)
        {
            self.presenter?.setCurrentPage(index: currentIndex)
        }
    }

    // UIPageViewControllerDataSource
    func pageViewController(
        _: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }

        let previousIndex = viewControllerIndex - 1

        guard previousIndex >= 0 else { return pages.last }

        return pages[previousIndex]
    }

    func pageViewController(
        _: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }

        let nextIndex = viewControllerIndex + 1

        guard nextIndex < pages.count else { return pages.first }

        return pages[nextIndex]
    }
}
