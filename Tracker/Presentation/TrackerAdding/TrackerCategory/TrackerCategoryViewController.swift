//
//  TrackerCategoryViewController.swift
//  Tracker
//
//  Created by Александр Бекренев on 19.06.2023.
//

import UIKit

final class TrackerCategoryViewController: UIViewController {
	private let titleLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = "Категория"
		label.font = .Medium.big
		label.textColor = .Dynamic.blackDay
		return label
	}()

	private let placeholderView = TrackerPlaceholderView()

	private let viewModel: TrackerCategoryViewModelProtocol
	private let helper: TrackerCategoryTableViewHelperProtocol
	
	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = .Dynamic.whiteDay
	}
	
	init(
		viewModel: TrackerCategoryViewModelProtocol,
		helper: TrackerCategoryTableViewHelperProtocol
	) {
		self.viewModel = viewModel
		self.helper = helper
		super.init(nibName: nil, bundle: nil)
		
		helper.delegate = self
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// MARK: - TrackerCategoryTableViewHelperDelagate
extension TrackerCategoryViewController: TrackerCategoryTableViewHelperDelegate {
	var categories: [TrackerCategory] {
		viewModel.categories
	}
	
	func didTapCategoryCell(category: TrackerCategory) {
		print(category.title)
	}
}
