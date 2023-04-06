//
//  TrackersCollectionViewCell.swift
//  Tracker
//
//  Created by Александр Бекренев on 02.04.2023.
//

import UIKit

final class TrackersCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: TrackersCollectionViewCell.self)
    
    private let trackerTitleLable = UILabel()
    private let emojiLabel = UILabel()
    private let topContainerView = UIView()
    private let dayCountLabel = UILabel()
    private let completeTrackerButton = CompleteTrackerButton()
    
    private var dayCount = 0 {
        didSet {
            dayCountLabel.text = "\(dayCount) дней"
        }
    }
    
    var tracker: Tracker? {
        didSet {
            guard let tracker = tracker else { return }
            topContainerView.backgroundColor = tracker.color
            trackerTitleLable.text = tracker.title
            emojiLabel.text = tracker.emoji
            emojiLabel.sizeToFit()
            completeTrackerButton.color = tracker.color
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupContainerView()
        setupDayCountLabel()
        setupFixTrackerButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - Setup and layout container view
private extension TrackersCollectionViewCell {
    func setupContainerView() {
        topContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(topContainerView)
        
        NSLayoutConstraint.activate([
            topContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            topContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            topContainerView.heightAnchor.constraint(equalToConstant: 90)
        ])
        
        topContainerView.layer.cornerRadius = 16
        
        setupEmojiLabel()
        setupTitleLable()
    }
}

// MARK: - Setup and layout title label
private extension TrackersCollectionViewCell {
    func setupTitleLable() {
        trackerTitleLable.translatesAutoresizingMaskIntoConstraints = false
        topContainerView.addSubview(trackerTitleLable)
        
        NSLayoutConstraint.activate([
            trackerTitleLable.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor, constant: 12),
            trackerTitleLable.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor, constant: -12),
            trackerTitleLable.topAnchor.constraint(equalTo: topContainerView.topAnchor, constant: 44),
            trackerTitleLable.bottomAnchor.constraint(equalTo: topContainerView.bottomAnchor, constant: -12),
        ])
        
        trackerTitleLable.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        trackerTitleLable.textColor = .white
        trackerTitleLable.numberOfLines = 0
    }
    
    func setupEmojiLabel() {
        let emojiBackgroundView = UIView()
        emojiBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        topContainerView.addSubview(emojiBackgroundView)
        
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        topContainerView.addSubview(emojiLabel)

        NSLayoutConstraint.activate([
            emojiBackgroundView.topAnchor.constraint(equalTo: topContainerView.topAnchor, constant: 12),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor, constant: 12),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),
        ])
        
        emojiBackgroundView.backgroundColor = .white.withAlphaComponent(0.3)
        emojiBackgroundView.layer.cornerRadius = 12
        emojiLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    }
}

// MARK: - Setup and layout day count label
private extension TrackersCollectionViewCell {
    func setupDayCountLabel() {
        dayCountLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dayCountLabel)
        
        NSLayoutConstraint.activate([
            dayCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            dayCountLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            dayCountLabel.widthAnchor.constraint(equalToConstant: 118),
            dayCountLabel.heightAnchor.constraint(equalToConstant: 18),
        ])
        
        dayCountLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        dayCountLabel.textColor = .trackerBlackDay
        dayCountLabel.text = "\(dayCount) дней"
    }
}

// MARK: - Setup and layout fix tracker button
private extension TrackersCollectionViewCell {
    func setupFixTrackerButton() {
        completeTrackerButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(completeTrackerButton)
        
        NSLayoutConstraint.activate([
            completeTrackerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            completeTrackerButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            completeTrackerButton.widthAnchor.constraint(equalToConstant: 34),
            completeTrackerButton.heightAnchor.constraint(equalToConstant: 34),
        ])
        completeTrackerButton.addTarget(self, action: #selector(didTapFixTrackerButton), for: .touchUpInside)
    }
    
    @objc
    func didTapFixTrackerButton() {
        if completeTrackerButton.isDone {
            dayCount -= 1
        } else {
            dayCount += 1
        }
    }
}
