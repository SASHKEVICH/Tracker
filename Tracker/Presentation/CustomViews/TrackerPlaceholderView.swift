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
            imageView.image = image
        }
    }

    private var text: String? {
        didSet {
            textLabel.text = text
        }
    }

    private var state: State?

    init() {
        super.init(frame: .zero)
        addSubviews()
        addConstraints()

        backgroundColor = .Dynamic.whiteDay
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
            set(image: .Placeholder.emptyForDay, text: text, newState: state)
        case .emptyTrackersSearch:
            let text = localizable.placeholderViewEmptySearchTextLabelText()
            set(image: .Placeholder.emptySearch, text: text, newState: state)
        case .emptyCategories:
            let text = localizable.placeholderViewEmptyCategoriesTextLabelText()
            set(image: .Placeholder.emptyForDay, text: text, newState: state)
        case .emptyStatistics:
            let text = localizable.placeholderViewEmptyStatisticsTextLabelText()
            set(image: .Placeholder.emptyStatistics, text: text, newState: state)
        }
    }

    func set(image: UIImage?, text: String?, newState: State) {
        guard state != newState else { return }

        UIView.transition(
            with: imageView,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: { [weak self] in
                self?.image = image
            }
        )

        UIView.transition(
            with: textLabel,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: { [weak self] in
                self?.text = text
            }
        )

        state = newState
    }
}

private extension TrackerPlaceholderView {
    func addSubviews() {
        addSubview(imageView)
        addSubview(textLabel)
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            textLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
        ])
    }
}
