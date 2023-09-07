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
    enum Event {
        case finish
    }

    var presenter: OnboardingViewPresenterProtocol?

    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.numberOfPages = self.presenter?.pagesCount ?? 0
        pageControl.currentPage = 0

        pageControl.currentPageIndicatorTintColor = .Static.black
        pageControl.pageIndicatorTintColor = .Static.black.withAlphaComponent(0.3)
        return pageControl
    }()

    private lazy var confirmOnboardingButton: TrackerCustomButton = {
        let buttonTitle = R.string.localizable.onboardingButtonTitle()
        let button = TrackerCustomButton(state: .onboarding, title: buttonTitle)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(self.didTapOnboardingButton), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self.presenter?.pagesViewControllerHelper
        self.delegate = self.presenter?.pagesViewControllerHelper

        self.setViewControllers()
        self.addSubviews()
        self.addConstraints()
    }
}

// MARK: - OnboardingViewControllerProtocol

extension OnboardingViewController: OnboardingViewControllerProtocol {
    func setCurrentPage(index: Int) {
        self.pageControl.currentPage = index
    }
}

// MARK: - Actions

private extension OnboardingViewController {
    @objc
    func didTapOnboardingButton() {
        self.presenter?.navigateToMainScreen(event: .finish)
    }
}

private extension OnboardingViewController {
    func setViewControllers() {
        guard let viewController = self.presenter?.pagesViewControllerHelper?.firstViewController else { return }
        self.setViewControllers([viewController], direction: .forward, animated: true, completion: nil)
    }

    func addSubviews() {
        self.view.addSubview(self.confirmOnboardingButton)
        self.view.addSubview(self.pageControl)
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            self.confirmOnboardingButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.confirmOnboardingButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            self.confirmOnboardingButton.bottomAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.bottomAnchor,
                constant: -50
            ),
            self.confirmOnboardingButton.heightAnchor.constraint(equalToConstant: 60),
        ])

        NSLayoutConstraint.activate([
            self.pageControl.bottomAnchor.constraint(equalTo: self.confirmOnboardingButton.topAnchor, constant: -24),
            self.pageControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
        ])
    }
}
