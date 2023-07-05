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

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupEmojiLabel()
        setupBackgroundView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension EmojisCollectionViewCell {
    func setupEmojiLabel() {
        contentView.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func setupBackgroundView() {
        let backgroundView = UIView()
        
        backgroundView.backgroundColor = .trackerLightGray
        backgroundView.layer.cornerRadius = 16
        backgroundView.layer.masksToBounds = true
        
        selectedBackgroundView = backgroundView
    }
}
