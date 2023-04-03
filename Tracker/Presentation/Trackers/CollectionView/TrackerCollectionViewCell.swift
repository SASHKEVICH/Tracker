//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Александр Бекренев on 02.04.2023.
//

import UIKit

final class TrackerCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: TrackerCollectionViewCell.self)
    
    private let trackerTitleLable = UILabel()
    private let emojiLabel = UILabel()
    private let containerView = UIView()
    
    private let dateCountLabel = UILabel()
    private var fixTrackerButton: UIButton?
    
    var tracker: Tracker?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupContainerView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - Setup and layout container view
private extension TrackerCollectionViewCell {
    func setupContainerView() {
        guard let tracker = tracker else { return }
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 90)
        ])
        
        containerView.backgroundColor = tracker.color
        containerView.layer.cornerRadius = 16
        
        setupEmojiLabel(tracker: tracker)
        setupTitleLable(tracker: tracker)
    }
}

// MARK: - Setup and layout title label
private extension TrackerCollectionViewCell {
    func setupTitleLable(tracker: Tracker) {
        trackerTitleLable.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(trackerTitleLable)
        
        NSLayoutConstraint.activate([
            trackerTitleLable.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            trackerTitleLable.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            trackerTitleLable.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
        
        trackerTitleLable.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        trackerTitleLable.text = tracker.title
    }
    
    func setupEmojiLabel(tracker: Tracker) {
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
        ])
        
        emojiLabel.backgroundColor = .white.withAlphaComponent(0.3)
        emojiLabel.layer.cornerRadius = trackerTitleLable.frame.size.height / 2
        emojiLabel.text = tracker.emoji
    }
}
