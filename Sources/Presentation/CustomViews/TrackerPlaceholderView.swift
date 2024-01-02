//
//  TrackerPlaceholderView.swift
//  Tracker
//
//  Created by Александр Бекренев on 02.04.2023.
//

import UIKit

final class TrackerPlaceholderView: UIView {
    enum State {
        case emptyTrackersForDay
        case emptyTrackersSearch
        case emptyCategories
        case emptyStatistics
    }

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let textLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.font = .Medium.medium
        textLabel.textColor = .Dynamic.blackDay
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 0
        return textLabel
    }()

    private var image: UIImage? {
        didSet {
            self.imageView.image = self.image
        }
    }

    private var text: String? {
        didSet {
            self.textLabel.text = self.text
        }
    }

    private var state: State?

    init() {
        super.init(frame: .zero)
        self.addSubviews()
        self.addConstraints()

        self.backgroundColor = .Dynamic.whiteDay
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension TrackerPlaceholderView {
    func set(state: TrackerPlaceholderView.State) {
        let localizable = R.string.localizable
        switch state {
        case .emptyTrackersForDay:
            let text = localizable.placeholderViewEmptyForDayTextLabelText()
            self.set(image: .Placeholder.emptyForDay, text: text, newState: state)
        case .emptyTrackersSearch:
            let text = localizable.placeholderViewEmptySearchTextLabelText()
            self.set(image: .Placeholder.emptySearch, text: text, newState: state)
        case .emptyCategories:
            let text = localizable.placeholderViewEmptyCategoriesTextLabelText()
            self.set(image: .Placeholder.emptyForDay, text: text, newState: state)
        case .emptyStatistics:
            let text = localizable.placeholderViewEmptyStatisticsTextLabelText()
            self.set(image: .Placeholder.emptyStatistics, text: text, newState: state)
        }
    }

    func set(image: UIImage?, text: String?, newState: State) {
        guard self.state != newState else { return }

        UIView.transition(
            with: self.imageView,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: { [weak self] in
                self?.image = image
            }
        )

        UIView.transition(
            with: self.textLabel,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: { [weak self] in
                self?.text = text
            }
        )

        self.state = newState
    }
}

private extension TrackerPlaceholderView {
    func addSubviews() {
        self.addSubview(imageView)
        self.addSubview(textLabel)
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            self.imageView.widthAnchor.constraint(equalToConstant: 80),
            self.imageView.heightAnchor.constraint(equalToConstant: 80),
            self.imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            self.textLabel.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 8),
            self.textLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.textLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            self.textLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16)
        ])
    }
}
