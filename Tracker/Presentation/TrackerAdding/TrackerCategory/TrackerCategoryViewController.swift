//
//  TrackerCategoryViewController.swift
//  Tracker
//
//  Created by Александр Бекренев on 19.06.2023.
//

import UIKit

final class TrackerCategoryViewController: UIViewController {
	private let viewModel: TrackerCategoryViewModelProtocol
	private let helper: TrackerCategoryTableViewHelperProtocol

	private let placeholderView = TrackerPlaceholderView()

	private let titleLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = "Категория"
		label.font = .Medium.big
		label.textColor = .Dynamic.blackDay
		label.sizeToFit()
		return label
	}()

	private lazy var categoriesTableView: UITableView = {
		let tableView = UITableView()
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.register(
			TrackerCategoryTableViewCell.self,
			forCellReuseIdentifier: TrackerCategoryTableViewCell.reuseIdentifier
		)
		tableView.dataSource = self.helper
		tableView.delegate = self.helper
		tableView.rowHeight = 75
		tableView.separatorStyle = .none
		return tableView
	}()

	private lazy var addCategoryButton: TrackerCustomButton = {
		let button = TrackerCustomButton(state: .normal, title: "Добавить категорию")
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
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

		self.addSubviews()
		self.addConstraints()
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
	
	func didChoose(category: TrackerCategory) {
		print(category.title)
	}
}

private extension TrackerCategoryViewController {
	func addSubviews() {
		view.addSubview(titleLabel)
		view.addSubview(categoriesTableView)
		view.addSubview(addCategoryButton)
	}

	func addConstraints() {
		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
			titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
		])

		NSLayoutConstraint.activate([
			categoriesTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
			categoriesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			categoriesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			categoriesTableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -15)
		])

		NSLayoutConstraint.activate([
			addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
			addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
		])
	}
}
