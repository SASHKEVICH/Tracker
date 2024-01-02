//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by Александр Бекренев on 24.05.2023.
//

import UIKit

protocol OnboardingViewControllerProtocol: AnyObject {
    var presenter: OnboardingViewPresenterProtocol? { get set }
    func setCurrentPage(index: Int)
}

final class OnboardingPageViewController: UIPageViewController {

    // MARK: - Internal properties

    var presenter: OnboardingViewPresenterProtocol?

    // MARK: - Private properties

    private let viewModel: OnboardingViewModelProtocol

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

    // MARK: - Init

    init(viewModel: OnboardingViewModelProtocol) {
        self.viewModel = viewModel
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides

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

extension OnboardingPageViewController: OnboardingViewControllerProtocol {
    func setCurrentPage(index: Int) {
        self.pageControl.currentPage = index
    }
}

// MARK: - Actions

extension OnboardingPageViewController {
    @objc
    private func didTapOnboardingButton() {
        self.viewModel.didTapOnboardingButton()
    }
}

private extension OnboardingPageViewController {
    enum Constants {
        static let buttonHorizontalSpacing: CGFloat = 20
        static let buttonBottomOffset: CGFloat = 50
        static let buttonHeight: CGFloat = 60

        static let pageControlTopOffset: CGFloat = 24
    }

    func setViewControllers() {
        guard let viewController = presenter?.pagesViewControllerHelper?.firstViewController else { return }
        self.setViewControllers([viewController], direction: .forward, animated: true, completion: nil)
    }

    func addSubviews() {
        self.view.addSubview(confirmOnboardingButton)
        self.view.addSubview(pageControl)
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            confirmOnboardingButton.leadingAnchor.constraint(
                equalTo: self.view.leadingAnchor,
                constant: Constants.buttonHorizontalSpacing
            ),
            confirmOnboardingButton.trailingAnchor.constraint(
                equalTo: self.view.trailingAnchor,
                constant: -Constants.buttonHorizontalSpacing
            ),
            confirmOnboardingButton.bottomAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.bottomAnchor,
                constant: -Constants.buttonBottomOffset
            ),
            confirmOnboardingButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])

        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(
                equalTo: self.confirmOnboardingButton.topAnchor,
                constant: -Constants.pageControlTopOffset
            ),
            pageControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
    }
}
