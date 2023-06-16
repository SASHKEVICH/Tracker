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
}

final class OnboardingViewPresenter {
    weak var view: OnboardingViewControllerProtocol?
	var pagesViewControllerHelper: OnboardingViewControllerHelperProtocol?
    
	init(helper: OnboardingViewControllerHelperProtocol) {
		setupPagesViewControllerHelper(helper)
	}
}

extension OnboardingViewPresenter: OnboardingViewPresenterProtocol {
	var pagesCount: Int {
		pagesViewControllerHelper?.pagesCount ?? 0
	}
	
	func setCurrentPage(index: Int) {
		view?.setCurrentPage(index: index)
	}
}

private extension OnboardingViewPresenter {
	func setupPagesViewControllerHelper(_ helper: OnboardingViewControllerHelperProtocol) {
		self.pagesViewControllerHelper = helper
		helper.presenter = self
	}
}
