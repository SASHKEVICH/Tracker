//
//  TrackerScheduleViewController.swift
//  Tracker
//
//  Created by Александр Бекренев on 15.04.2023.
//

import UIKit

protocol TrackerScheduleViewControllerProtocol: AnyObject {
    var presenter: TrackerSchedulePresenterProtocol? { get set }
    var delegate: TrackerScheduleViewControllerDelegate? { get set }
}

final class TrackerScheduleViewController: UIViewController, TrackerScheduleViewControllerProtocol {
    private let titleLabel = UILabel()
    private let scheduleTableView = UITableView()
    private let addScheduleButton = TrackerCustomButton(state: .normal, title: "Готово")
    
    private let trackerScheduleConfiguration = TrackerScheduleConstants.configuration
    
    weak var delegate: TrackerScheduleViewControllerDelegate?
    var presenter: TrackerSchedulePresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .trackerWhiteDay
        
        setupTitleLabel()
        setupAddScheduleButton()
        setupScheduleTableView()
    }
}

private extension TrackerScheduleViewController {
    func setupTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .trackerBlackDay
        titleLabel.text = "Расписание"
    }
    
    func setupScheduleTableView() {
        view.addSubview(scheduleTableView)
        scheduleTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scheduleTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scheduleTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scheduleTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            scheduleTableView.bottomAnchor.constraint(equalTo: addScheduleButton.topAnchor, constant: -47)
        ])
        
        scheduleTableView.delegate = presenter?.scheduleTableViewHelper
        scheduleTableView.dataSource = presenter?.scheduleTableViewHelper
        scheduleTableView.register(TrackerScheduleTableViewCell.self, forCellReuseIdentifier: TrackerScheduleTableViewCell.identifier)
        scheduleTableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func setupAddScheduleButton() {
        view.addSubview(addScheduleButton)
        addScheduleButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addScheduleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addScheduleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addScheduleButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -1 * trackerScheduleConfiguration.bottomConstantConstraint),
            addScheduleButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        addScheduleButton.addTarget(self, action: #selector(didTapAddScheduleButton), for: .touchUpInside)
    }
}

private extension TrackerScheduleViewController {
    @objc
    func didTapAddScheduleButton() {
        guard let selectedWeekDays = presenter?.selectedWeekDays else { return }
        delegate?.didRecieveSelectedWeekDays(selectedWeekDays)
        delegate?.dismissTrackerScheduleViewController()
    }
}
