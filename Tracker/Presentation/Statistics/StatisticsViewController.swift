//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Александр Бекренев on 31.03.2023.
//

import UIKit

final class StatisticsViewController: UIViewController {
	private let viewModel: StatisticsViewModelProtocol

	init(viewModel: StatisticsViewModelProtocol) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
		view.backgroundColor = .Dynamic.whiteDay
		self.setupNavigationItem()
    }
}

private extension StatisticsViewController {
	func setupNavigationItem() {
		self.navigationItem.largeTitleDisplayMode = .always
		self.navigationItem.title = R.string.localizable.statisticsNavigationItemTitle()
		self.definesPresentationContext = true
	}
}
