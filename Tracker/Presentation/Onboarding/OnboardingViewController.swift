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
		
		pageControl.currentPageIndicatorTintColor = .Dynamic.blackDay
		pageControl.pageIndicatorTintColor = .Dynamic.blackDay.withAlphaComponent(0.3)
		
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
        
		self.dataSource = self.presenter?.pagesViewControllerHelper
		self.delegate = self.presenter?.pagesViewControllerHelper
		
		self.setViewControllers()
		self.addSubviews()
		self.addConstraints()
		
		self.confirmOnboardingButton.addTarget(self, action: #selector(self.didTapOnboardingButton), for: .touchUpInside)
    }
}

// MARK: - OnboardingViewControllerProtocol
extension OnboardingViewController: OnboardingViewControllerProtocol {
	func setCurrentPage(index: Int) {
		self.pageControl.currentPage = index
	}
}

// MARK: - Onboarding button callback
extension OnboardingViewController {
	@objc
	private func didTapOnboardingButton() {
		self.presenter?.navigateToMainScreen()
	}
}

private extension OnboardingViewController {
	func setViewControllers() {
		guard let viewController = presenter?.pagesViewControllerHelper?.firstViewController else { return }
		self.setViewControllers([viewController], direction: .forward, animated: true, completion: nil)
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
		self.view.addSubview(confirmOnboardingButton)
		self.view.addSubview(pageControl)
	}
}
