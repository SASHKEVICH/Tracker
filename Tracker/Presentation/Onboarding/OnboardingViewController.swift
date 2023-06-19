//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Александр Бекренев on 24.05.2023.
//

import UIKit

protocol OnboardingViewControllerProtocol: AnyObject {
    var presenter: OnboardingViewPresenterProtocol? { get set }
	func setCurrentPage(index: Int)
}

// MARK: - OnboardingViewController
final class OnboardingViewController: UIPageViewController {
    var presenter: OnboardingViewPresenterProtocol?
	
	private lazy var pageControl: UIPageControl = {
		let pageControl = UIPageControl()
		pageControl.numberOfPages = presenter?.pagesCount ?? 0
		pageControl.currentPage = 0
		
		pageControl.currentPageIndicatorTintColor = .trackerBlackDay
		pageControl.pageIndicatorTintColor = .trackerBlackDay.withAlphaComponent(0.3)
		
		pageControl.translatesAutoresizingMaskIntoConstraints = false
		return pageControl
	}()

	private let confirmOnboardingButton: TrackerCustomButton = {
		let button = TrackerCustomButton(state: .normal, title: "Вот это технологии!")
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
		dataSource = presenter?.pagesViewControllerHelper
		delegate = presenter?.pagesViewControllerHelper
		
        setViewControllers()
		addSubviews()
		addConstraints()
		
		confirmOnboardingButton.addTarget(self, action: #selector(didTapOnboardingButton), for: .touchUpInside)
    }
}

// MARK: - OnboardingViewControllerProtocol
extension OnboardingViewController: OnboardingViewControllerProtocol {
	func setCurrentPage(index: Int) {
		pageControl.currentPage = index
	}
}

// MARK: - Onboarding button callback
extension OnboardingViewController {
	@objc
	private func didTapOnboardingButton() {
		let tabBarController = TabBarViewController()
		tabBarController.modalPresentationStyle = .fullScreen
		tabBarController.modalTransitionStyle = .coverVertical
		present(tabBarController, animated: true)
	}
}

private extension OnboardingViewController {
	func setViewControllers() {
		guard let viewController = presenter?.pagesViewControllerHelper?.firstViewController else { return }
		setViewControllers([viewController], direction: .forward, animated: true, completion: nil)
	}
	
	func addConstraints() {
		NSLayoutConstraint.activate([
			confirmOnboardingButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			confirmOnboardingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			confirmOnboardingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
			confirmOnboardingButton.heightAnchor.constraint(equalToConstant: 60)
		])
		
		NSLayoutConstraint.activate([
			pageControl.bottomAnchor.constraint(equalTo: confirmOnboardingButton.topAnchor, constant: -24),
			pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
		])
	}
	
	func addSubviews() {
		view.addSubview(confirmOnboardingButton)
		view.addSubview(pageControl)
	}
}
