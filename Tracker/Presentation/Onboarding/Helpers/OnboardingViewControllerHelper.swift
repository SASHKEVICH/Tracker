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
	
	lazy var pages: [UIViewController] = {
		let firstPage = OnboardingFirstPageViewController()
		firstPage.view.backgroundColor = .red
		
		let secondPage = OnboardingSecondPageViewController()
		secondPage.view.backgroundColor = .blue
		
		return [firstPage, secondPage]
	}()
}

extension OnboardingViewControllerHelper: OnboardingViewControllerHelperProtocol {
	var firstViewController: UIViewController? {
		pages.first
	}
	
	var pagesCount: Int {
		pages.count
	}
	
	// UIPageViewControllerDelegate
	
	// UIPageViewControllerDataSource
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
		guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
		
		let previousIndex = viewControllerIndex - 1
		
		guard previousIndex >= 0 else { return pages.last }
		
		return pages[previousIndex]
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
		guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
				
		let nextIndex = viewControllerIndex + 1
		
		guard nextIndex < pages.count else { return pages.first }
		
		return pages[nextIndex]
    }
}
