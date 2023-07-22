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
        label.text = R.string.localizable.trackerTypeViewControllerTitle()
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
        let title = R.string.localizable.trackerTypeAddTrackerButtonTitle()
        let button = TrackerCustomButton(state: .normal, title: title)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(self.didTapAddTrackerButton), for: .touchUpInside)
        return button
    }()

    private lazy var addIrregularEventButton = {
        let title = R.string.localizable.trackerTypeAddIrregularEventButtonTitle()
        let button = TrackerCustomButton(state: .normal, title: title)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(self.didTapAddIrregularEventButton), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .Dynamic.whiteDay

        addSubviews()
        addConstraints()
    }
}

// MARK: - TrackerTypeViewControllerProtocol

extension TrackerTypeViewController: TrackerTypeViewControllerProtocol {}

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
        ])

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 136),
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
        presenter?.navigateToTrackerScreen()
    }

    @objc
    func didTapAddIrregularEventButton() {
        presenter?.navigateToIrregularEventScreen()
    }
}
