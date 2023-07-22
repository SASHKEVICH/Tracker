//
//  EmojiCollectionViewCell.swift
//  Tracker
//
//  Created by Александр Бекренев on 26.04.2023.
//

import UIKit

final class EmojisCollectionViewCell: UICollectionViewCell {
    var emoji: String? {
        didSet {
            emojiLabel.text = emoji
        }
    }

    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 32, weight: .bold)
        return label
    }()

    private let selectBackgroundView = CellSelectBackgroundView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubviews()
        self.addConstraints()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setupBackgroundView()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension EmojisCollectionViewCell {
    func addSubviews() {
        contentView.addSubview(emojiLabel)
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    func setupBackgroundView() {
        selectedBackgroundView = selectBackgroundView
    }
}
