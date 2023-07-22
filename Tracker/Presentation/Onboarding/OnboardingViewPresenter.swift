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
    func navigateToMainScreen(animated: Bool)
}

final class OnboardingViewPresenter {
    weak var view: OnboardingViewControllerProtocol?
    var pagesViewControllerHelper: OnboardingViewControllerHelperProtocol?

    private let router: OnboardingRouterProtocol

    init(helper: OnboardingViewControllerHelperProtocol, router: OnboardingRouterProtocol) {
        self.router = router
        pagesViewControllerHelper = helper

        helper.presenter = self
    }
}

// MARK: - OnboardingViewPresenterProtocol

extension OnboardingViewPresenter: OnboardingViewPresenterProtocol {
    var pagesCount: Int {
        pagesViewControllerHelper?.pagesCount ?? 0
    }

    func setCurrentPage(index: Int) {
        view?.setCurrentPage(index: index)
    }

    func navigateToMainScreen(animated: Bool) {
        router.navigateToMainScreen(animated: animated)
    }
}
