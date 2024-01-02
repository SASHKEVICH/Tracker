//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by Александр Бекренев on 24.05.2023.
//

import UIKit

final class OnboardingPageViewController: UIPageViewController {

    // MARK: - Private properties

    private let viewModel: OnboardingViewModelProtocol
    private let pageViewDelegate: UIPageViewControllerDelegate
    private let pageViewDataSource: OnboardingPageControllerDataSource

    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.numberOfPages = self.pageViewDataSource.pagesCount
        pageControl.currentPage = self.pageViewDataSource.currentPage

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

    init(
        viewModel: OnboardingViewModelProtocol,
        pageViewDelegate: UIPageViewControllerDelegate,
        pageViewDataSource: OnboardingPageControllerDataSource
    ) {
        self.viewModel = viewModel
        self.pageViewDelegate = pageViewDelegate
        self.pageViewDataSource = pageViewDataSource

        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)

        self.delegate = pageViewDelegate
        self.dataSource = pageViewDataSource
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setViewControllers()
        self.addSubviews()
        self.addConstraints()
        self.bind()
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
        guard let viewController = self.pageViewDataSource.firstViewController else { return }
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

    func bind() {
        self.viewModel.currentPageIndex.bind { [weak self] index in
            self?.pageControl.currentPage = index
        }
    }
}
