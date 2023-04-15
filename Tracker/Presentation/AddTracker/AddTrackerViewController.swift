//
//  AddTrackerViewController.swift
//  Tracker
//
//  Created by Александр Бекренев on 14.04.2023.
//

import UIKit

protocol AddTrackerViewControllerProtocol: AnyObject {
    var presenter: AddTrackerViewPresenterProtocol? { get set }
}

enum TrackerType {
    case tracker
    case irregularEvent
}

final class AddTrackerViewController: UIViewController, AddTrackerViewControllerProtocol {
    private let titleLabel = UILabel()
    private let trackerTitleTextField = TrackerTitleTextField()
    
    private var trackerOptionsTableView: UITableView?
    
    private var titleText: String? {
        didSet {
            titleLabel.text = titleText
            titleLabel.sizeToFit()
        }
    }
    
    var trackerType: TrackerType?
    var presenter: AddTrackerViewPresenterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .trackerWhiteDay
        
        setupTitleLabel()
        setupViewControllerForGivenType()
        setupTrackerTitleTextField()
        setupTableView()
        
        if let trackerType = trackerType {
            presenter?.viewDidLoad(type: trackerType)
            trackerOptionsTableView?.reloadData()
        }
    }
}

private extension AddTrackerViewController {
    func setupTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .trackerBlackDay
    }
    
    func setupTrackerTitleTextField() {
        view.addSubview(trackerTitleTextField)
        trackerTitleTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            trackerTitleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerTitleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackerTitleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            trackerTitleTextField.heightAnchor.constraint(equalToConstant: 75)
        ])
        
        trackerTitleTextField.placeholder = "Введите название трекера"
    }
    
    func setupTableView() {
        let tableView = UITableView()
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: trackerTitleTextField.bottomAnchor, constant: 24),
            tableView.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        tableView.dataSource = presenter?.tableViewHelper
        tableView.delegate = presenter?.tableViewHelper
        tableView.register(TrackerOptionsTableViewCell.self, forCellReuseIdentifier: TrackerOptionsTableViewCell.identifier)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        self.trackerOptionsTableView = tableView
    }
    
    func setupViewControllerForGivenType() {
        guard let type = trackerType else { return }
        switch type {
        case .tracker:
            titleText = "Новая привычка"
        case .irregularEvent:
            titleText = "Новое нерегулярное событие"
        }
    }
}
