//
//  TrackerScheduleViewController.swift
//  Tracker
//
//  Created by Александр Бекренев on 15.04.2023.
//

import UIKit

protocol TrackerScheduleViewControllerDelegate: AnyObject {
	func didRecieveSelectedWeekDays(_ weekDays: Set<WeekDay>)
}

protocol TrackerScheduleViewControllerProtocol: AnyObject {
    var presenter: TrackerSchedulePresenterProtocol? { get set }
    var delegate: TrackerScheduleViewControllerDelegate? { get set }
}

final class TrackerScheduleViewController: UIViewController, TrackerScheduleViewControllerProtocol {
	weak var delegate: TrackerScheduleViewControllerDelegate?
	var presenter: TrackerSchedulePresenterProtocol?

	private let titleLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .Medium.big
		label.textColor = .Dynamic.blackDay
		label.text = R.string.localizable.trackerAddingOptionTitleSchedule()
		return label
	}()

	private lazy var scheduleTableView: UITableView = {
		let tableView = UITableView()
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.delegate = self.presenter?.scheduleTableViewHelper
		tableView.dataSource = self.presenter?.scheduleTableViewHelper
		tableView.register(
			TrackerScheduleTableViewCell.self,
			forCellReuseIdentifier: TrackerScheduleTableViewCell.reuseIdentifier
		)
		tableView.separatorColor = .Static.gray
		return tableView
	}()

	private lazy var addScheduleButton: TrackerCustomButton = {
		let title = R.string.localizable.trackerScheduleAddScheduleButtonTitle()
		let button = TrackerCustomButton(state: .normal, title: title)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(self.didTapAddScheduleButton), for: .touchUpInside)
		return button
	}()
    
    private let trackerScheduleConfiguration = TrackerScheduleConstants.configuration
    
    override func viewDidLoad() {
        super.viewDidLoad()

		view.backgroundColor = .Dynamic.whiteDay
        
		self.addSubviews()
		self.addConstraints()
    }
}

private extension TrackerScheduleViewController {
	func addSubviews() {
		view.addSubview(titleLabel)
		view.addSubview(scheduleTableView)
		view.addSubview(addScheduleButton)
	}

	func addConstraints() {
		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
			titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
		])

		NSLayoutConstraint.activate([
			scheduleTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			scheduleTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			scheduleTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
			scheduleTableView.bottomAnchor.constraint(equalTo: addScheduleButton.topAnchor, constant: -47)
		])

		NSLayoutConstraint.activate([
			addScheduleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			addScheduleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			addScheduleButton.bottomAnchor.constraint(
				equalTo: view.safeAreaLayoutGuide.bottomAnchor,
				constant: -1 * trackerScheduleConfiguration.bottomConstantConstraint),
			addScheduleButton.heightAnchor.constraint(equalToConstant: 60)
		])
	}
}

// MARK: - Actions
private extension TrackerScheduleViewController {
    @objc
    func didTapAddScheduleButton() {
		guard let selectedWeekDays = self.presenter?.selectedWeekDays else { return }
		self.delegate?.didRecieveSelectedWeekDays(selectedWeekDays)
    }
}
