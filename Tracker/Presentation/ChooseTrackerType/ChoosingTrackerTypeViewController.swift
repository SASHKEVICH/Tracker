//
//  ChoosingTrackerTypeViewController.swift
//  Tracker
//
//  Created by Александр Бекренев on 13.04.2023.
//

import UIKit

final class ChoosingTrackerTypeViewController: UIViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Создание трекера"
        label.sizeToFit()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .trackerBlackDay
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
    
    private let addTrackerButton = UIButton(type: .system)
    private let addIrregularEventButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .trackerWhiteDay
        
        addSubviews()
        applyConstraints()
        setupButtons()
    }
}

// MARK: - Setupping layout
private extension ChoosingTrackerTypeViewController {
    func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(stackView)
        
        stackView.addArrangedSubview(addTrackerButton)
        stackView.addArrangedSubview(addIrregularEventButton)
    }
    
    func applyConstraints() {
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
        [addTrackerButton, addIrregularEventButton].forEach {
            $0.backgroundColor = .trackerBlackDay
            
            $0.setTitleColor(.trackerWhiteDay, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            
            $0.layer.cornerRadius = 16
            $0.layer.masksToBounds = true
        }
        
        addTrackerButton.setTitle("Привычка", for: .normal)
        addIrregularEventButton.setTitle("Нерегулярное событие", for: .normal)
        
        addTrackerButton.addTarget(self, action: #selector(didTapAddTrackerButton), for: .touchUpInside)
        addIrregularEventButton.addTarget(self, action: #selector(didTapAddIrregularEventButton), for: .touchUpInside)
    }
}

// MARK: - Buttons callbacks
private extension ChoosingTrackerTypeViewController {
    @objc
    func didTapAddTrackerButton() {
        let vc = AddTrackerViewController()
        let presenter = AddTrackerViewPresenter(
            trackersService: TrackersService.shared,
            trackerType: .tracker)
        vc.presenter = presenter
        presenter.view = vc
        
        present(vc, animated: true)
    }
    
    @objc
    func didTapAddIrregularEventButton() {
        let vc = AddTrackerViewController()
        let presenter = AddTrackerViewPresenter(
            trackersService: TrackersService.shared,
            trackerType: .irregularEvent)
        vc.presenter = presenter
        presenter.view = vc
        
        present(vc, animated: true)
    }
}
