//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Александр Бекренев on 31.03.2023.
//

import UIKit

final class StatisticsViewController: UIViewController {
	private lazy var placeholderView: TrackerPlaceholderView = {
		let view = TrackerPlaceholderView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.set(state: .emptyStatistics)
		view.isHidden = self.viewModel.isPlaceholderHidden
		return view
	}()

	private var viewModel: StatisticsViewModelProtocol

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
		self.addSubviews()
		self.addConstraints()
		self.bind()
    }
}

private extension StatisticsViewController {
	func setupNavigationItem() {
		self.navigationItem.largeTitleDisplayMode = .always
		self.navigationItem.title = R.string.localizable.statisticsNavigationItemTitle()
		self.definesPresentationContext = true
	}

	func addSubviews() {
		self.view.addSubview(placeholderView)
	}

	func addConstraints() {
		NSLayoutConstraint.activate([
			placeholderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			placeholderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			placeholderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			placeholderView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		])
	}

	func bind() {
		self.viewModel.onIsPlaceholderHiddenChanged = { [weak self] in
			guard let self = self else { return }
			self.placeholderView.isHidden = self.viewModel.isPlaceholderHidden
		}
	}
}
