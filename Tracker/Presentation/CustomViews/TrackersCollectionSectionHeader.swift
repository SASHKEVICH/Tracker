//
//  TrackersCollectionSectionHeader.swift
//  Tracker
//
//  Created by Александр Бекренев on 05.04.2023.
//

import UIKit

final class TrackersCollectionSectionHeader: UICollectionReusableView {
    static let reuseIdentifier = String(describing: TrackersCollectionSectionHeader.self)

    var headerText: String? {
        didSet {
            headerLabel.text = headerText
            headerLabel.sizeToFit()
        }
    }

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .Bold.small
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        addConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

private extension TrackersCollectionSectionHeader {
    func addSubviews() {
        addSubview(headerLabel)
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            headerLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
        ])
    }
}
