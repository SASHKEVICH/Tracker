//
//  EmojiCollectionViewCell.swift
//  Tracker
//
//  Created by Александр Бекренев on 26.04.2023.
//

import UIKit

final class EmojisCollectionViewCell: UICollectionViewCell {
    static let identifier = String(describing: EmojisCollectionViewCell.self)
    
    private let emojiLabel = UILabel()
    
    var emoji: String? {
        didSet {
            emojiLabel.text = emoji
        }
    }
        
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
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        emojiLabel.font = .systemFont(ofSize: 32, weight: .bold)
    }
    
    func setupBackgroundView() {
        let backgroundView = UIView()
        
        backgroundView.backgroundColor = .trackerLightGray
        backgroundView.layer.cornerRadius = 16
        backgroundView.layer.masksToBounds = true
        
        selectedBackgroundView = backgroundView
    }
}
