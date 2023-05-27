//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Александр Бекренев on 24.05.2023.
//

import UIKit

protocol OnboardingViewControllerProtocol: AnyObject {
    var presenter: OnboardingViewPresenterProtocol? { get set }
}

final class OnboardingViewController: UIPageViewController {
    var presenter: OnboardingViewPresenterProtocol?
    
    lazy var confirmOnboardingButton: UIButton = {
        let button = UIButton()
        return button
    }()
	
	lazy var pageControl: UIPageControl = {
		let pageControl = UIPageControl()
		pageControl.numberOfPages = presenter?.pagesCount ?? 0
		pageControl.currentPage = 0
		
		pageControl.currentPageIndicatorTintColor = .brown
		pageControl.pageIndicatorTintColor = .orange
		
		pageControl.translatesAutoresizingMaskIntoConstraints = false
		return pageControl
	}()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
		dataSource = presenter?.pagesViewControllerHelper
		delegate = presenter?.pagesViewControllerHelper
        setViewControllers()
    }

}

extension OnboardingViewController: OnboardingViewControllerProtocol {
    
}

private extension OnboardingViewController {
	func setViewControllers() {
		guard let viewController = presenter?.pagesViewControllerHelper?.firstViewController else { return }
		setViewControllers([viewController], direction: .forward, animated: true, completion: nil)
	}
	
	func layoutPageControl() {
		view.addSubview(pageControl)
		
		NSLayoutConstraint.activate([
			pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			pageControl.widthAnchor.constraint(equalToConstant: 18),
			pageControl.heightAnchor.constraint(equalToConstant: 6),
		])
	}
}
