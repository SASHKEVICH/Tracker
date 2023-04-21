//
//  ChooseTrackerTypeViewController.swift
//  Tracker
//
//  Created by Александр Бекренев on 13.04.2023.
//

import UIKit

final class ChooseTrackerTypeViewController: UIViewController {
    private let titleLabel = UILabel()
    private let addTrackerButton = UIButton(type: .system)
    private let addIrregularEventButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .trackerWhiteDay
        
        setupTitleLabel()
        setupButtons()
    }
}

// MARK: - Setup Title Label
private extension ChooseTrackerTypeViewController {
    func setupTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        titleLabel.text = "Создание трекера"
        titleLabel.sizeToFit()
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .trackerBlackDay
    }
}

private extension ChooseTrackerTypeViewController {
    func setupButtons() {
        [addTrackerButton, addIrregularEventButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                $0.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                $0.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                $0.heightAnchor.constraint(equalToConstant: 60),
            ])
            
            $0.backgroundColor = .trackerBlackDay
            
            $0.setTitleColor(.trackerWhiteDay, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            
            $0.layer.cornerRadius = 16
            $0.layer.masksToBounds = true
        }
        
        addTrackerButton.setTitle("Привычка", for: .normal)
        addIrregularEventButton.setTitle("Нерегулярное событие", for: .normal)
        
        addIrregularEventButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -247).isActive = true
        addTrackerButton.bottomAnchor.constraint(equalTo: addIrregularEventButton.topAnchor, constant: -16).isActive = true
        
        addTrackerButton.addTarget(self, action: #selector(didTapAddTrackerButton), for: .touchUpInside)
        addIrregularEventButton.addTarget(self, action: #selector(didTapAddIrregularEventButton), for: .touchUpInside)
    }
    
    @objc
    func didTapAddTrackerButton() {
        let vc = AddTrackerViewController()
        let presenter = AddTrackerViewPresenter()
        vc.presenter = presenter
        presenter.view = vc
        
        vc.trackerType = .tracker
        present(vc, animated: true)
    }
    
    @objc
    func didTapAddIrregularEventButton() {
        let vc = AddTrackerViewController()
        let presenter = AddTrackerViewPresenter()
        vc.presenter = presenter
        presenter.view = vc
        
        vc.trackerType = .irregularEvent
        present(vc, animated: true)
    }
}
