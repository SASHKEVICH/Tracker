//
//  TrackerTypeViewController.swift
//  Tracker
//
//  Created by Александр Бекренев on 13.04.2023.
//

import UIKit

final class TrackerTypeViewController: UIViewController {
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
    
	private let addTrackerButton = TrackerCustomButton(state: .normal, title: "Привычка")
	private let addIrregularEventButton = TrackerCustomButton(state: .normal, title: "Нерегулярное событие")
    
    override func viewDidLoad() {
        super.viewDidLoad()
		view.backgroundColor = .Dynamic.whiteDay
        
        addSubviews()
        addConstraints()
        setupButtons()
    }
}

// MARK: - Setupping layout
private extension TrackerTypeViewController {
    func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(stackView)
        
        stackView.addArrangedSubview(addTrackerButton)
        stackView.addArrangedSubview(addIrregularEventButton)
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 136),
            
            addTrackerButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            addTrackerButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            addIrregularEventButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            addIrregularEventButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
        ])
    }
    
    func setupButtons() {
        addTrackerButton.addTarget(self, action: #selector(didTapAddTrackerButton), for: .touchUpInside)
        addIrregularEventButton.addTarget(self, action: #selector(didTapAddIrregularEventButton), for: .touchUpInside)
    }
}

// MARK: - Buttons callbacks
private extension TrackerTypeViewController {
    @objc
    func didTapAddTrackerButton() {
		self.presentAddingViewController(trackerType: .tracker)
    }
    
    @objc
    func didTapAddIrregularEventButton() {
		self.presentAddingViewController(trackerType: .irregularEvent)
    }
	
	func presentAddingViewController(trackerType: Tracker.TrackerType) {
		guard let addingService = TrackersAddingService(trackersFactory: TrackersFactory()) else {
			assertionFailure("Cannot init trackers adding service")
			return
		}

		let vc = TrackerAddingViewController()
		let presenter = TrackerAddingViewPresenter(
			trackersAddingService: addingService,
			trackerType: trackerType
		)
		vc.presenter = presenter
		presenter.view = vc

		vc.emptyTap = { [weak vc] in
			vc?.view.endEditing(true)
		}
		
		present(vc, animated: true)
	}
}
