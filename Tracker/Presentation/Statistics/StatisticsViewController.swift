//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Александр Бекренев on 31.03.2023.
//

import UIKit

final class StatisticsViewController: UIViewController {
	private lazy var statisticsTableView: UITableView = {
		let tableView = UITableView()
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.register(StatisticsTableViewCell.self, forCellReuseIdentifier: StatisticsTableViewCell.reuseIdentifier)
		tableView.dataSource = self.tableViewHelper
		tableView.delegate = self.tableViewHelper
		tableView.backgroundColor = .Dynamic.whiteDay
		tableView.separatorStyle = .none
		tableView.allowsSelection = false
		tableView.contentInset = UIEdgeInsets(top: 77, left: 0, bottom: 0, right: 0)
		return tableView
	}()

	private lazy var placeholderView: TrackerPlaceholderView = {
		let view = TrackerPlaceholderView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.set(state: .emptyStatistics)
		return view
	}()

	private var viewModel: StatisticsViewModelProtocol

	private let tableViewHelper: StatisticsTableViewHelperProtocol

	init(viewModel: StatisticsViewModelProtocol, tableViewHelper: StatisticsTableViewHelperProtocol) {
		self.viewModel = viewModel
		self.tableViewHelper = tableViewHelper
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
		view.backgroundColor = .Dynamic.whiteDay
		self.setupNavigationItem()
		self.addSubviews()
		self.addConstraints()
		self.bind()
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.statisticsTableView.reloadData()
		self.viewModel.fetchCompletedTrackers()
	}
}

// MARK: - StatisticsTableViewHelperDelegate
extension StatisticsViewController: StatisticsTableViewHelperDelegate {
	var statistics: [Statistics] {
		Array(self.viewModel.statistics)
	}
}

private extension StatisticsViewController {
	func setupNavigationItem() {
		self.navigationItem.largeTitleDisplayMode = .always
		self.navigationItem.title = R.string.localizable.statisticsNavigationItemTitle()
		self.definesPresentationContext = true
	}

	func addSubviews() {
		self.view.addSubview(statisticsTableView)
		self.view.insertSubview(placeholderView, aboveSubview: statisticsTableView)
	}

	func addConstraints() {
		NSLayoutConstraint.activate([
			placeholderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			placeholderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			placeholderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			placeholderView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		])

		NSLayoutConstraint.activate([
			statisticsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			statisticsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			statisticsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			statisticsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		])
	}

	func bind() {
		self.viewModel.onIsPlaceholderHiddenChanged = { [weak self] in
			guard let self = self else { return }
			self.placeholderView.isHidden = self.viewModel.isPlaceholderHidden
		}

		self.viewModel.onStatisticsChanged = { [weak self] in
			self?.statisticsTableView.reloadData()
		}
	}
}
