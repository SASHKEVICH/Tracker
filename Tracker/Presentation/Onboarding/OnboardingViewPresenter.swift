//
//  OnboardingViewPresenter.swift
//  Tracker
//
//  Created by Александр Бекренев on 24.05.2023.
//

import Foundation

protocol OnboardingViewPresenterProtocol: AnyObject {
    var view: OnboardingViewControllerProtocol? { get set }
    var pagesViewControllerHelper: OnboardingViewControllerHelperProtocol? { get }
    var pagesCount: Int { get }
    func setCurrentPage(index: Int)
    func navigateToMainScreen(event: OnboardingViewController.Event)
}

final class OnboardingViewPresenter {
    weak var view: OnboardingViewControllerProtocol?
    var pagesViewControllerHelper: OnboardingViewControllerHelperProtocol?

    var onNavigateToTabBar: ((OnboardingViewController.Event) -> Void)?

    init(helper: OnboardingViewControllerHelperProtocol) {
        self.pagesViewControllerHelper = helper
        helper.presenter = self
    }
}

// MARK: - OnboardingViewPresenterProtocol

extension OnboardingViewPresenter: OnboardingViewPresenterProtocol {
    var pagesCount: Int {
        self.pagesViewControllerHelper?.pagesCount ?? 0
    }

    func setCurrentPage(index: Int) {
        self.view?.setCurrentPage(index: index)
    }

    func navigateToMainScreen(event: OnboardingViewController.Event) {
        self.onNavigateToTabBar?(event)
    }
}
