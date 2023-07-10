//
//  TrackerTypeViewController.swift
//  Tracker
//
//  Created by Александр Бекренев on 13.04.2023.
//

import UIKit

protocol TrackerTypeViewControllerProtocol {
	var presenter: TrackerTypePresenterProtocol? { get set }
}

final class TrackerTypeViewController: UIViewController {
	var presenter: TrackerTypePresenterProtocol?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Создание трекера"
		label.font = .Medium.big
		label.textColor = .Dynamic.blackDay
		label.sizeToFit()
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        return stackView
    }()
    
	private lazy var addTrackerButton = {
		let button = TrackerCustomButton(state: .normal, title: "Привычка")
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(self.didTapAddTrackerButton), for: .touchUpInside)
		return button
	}()

	private lazy var addIrregularEventButton = {
		let button = TrackerCustomButton(state: .normal, title: "Нерегулярное событие")
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(self.didTapAddIrregularEventButton), for: .touchUpInside)
		return button
	}()
    
    override func viewDidLoad() {
        super.viewDidLoad()
		self.view.backgroundColor = .Dynamic.whiteDay
        
		self.addSubviews()
		self.addConstraints()
    }
}

// MARK: - TrackerTypeViewControllerProtocol
extension TrackerTypeViewController: TrackerTypeViewControllerProtocol {}

// MARK: - Setupping layout
private extension TrackerTypeViewController {
    func addSubviews() {
		self.view.addSubview(self.titleLabel)
		self.view.addSubview(self.stackView)
        
		self.stackView.addArrangedSubview(self.addTrackerButton)
		self.stackView.addArrangedSubview(self.addIrregularEventButton)
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			stackView.heightAnchor.constraint(equalToConstant: 136)
		])

		NSLayoutConstraint.activate([
			addTrackerButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
			addTrackerButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
			addIrregularEventButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
			addIrregularEventButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
		])
    }
}

// MARK: - Buttons callbacks
private extension TrackerTypeViewController {
    @objc
    func didTapAddTrackerButton() {
		self.presenter?.navigateToTrackerScreen()
    }
    
    @objc
    func didTapAddIrregularEventButton() {
		self.presenter?.navigateToIrregularEventScreen()
    }
}
