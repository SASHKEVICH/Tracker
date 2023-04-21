//
//  TrackerOptionsTableViewCell.swift
//  Tracker
//
//  Created by Александр Бекренев on 14.04.2023.
//

import UIKit

final class TrackerOptionsTableViewCell: UITableViewCell {
    static let identifier = String(describing: TrackerOptionsTableViewCell.self)
    
    private let cellTitleLabel = UILabel()
    private let additionalInfoLabel = UILabel()
    private let selectBackgroundView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    var cellTitle: String? {
        didSet {
            cellTitleLabel.text = cellTitle
            cellTitleLabel.sizeToFit()
        }
    }
    
    var additionalInfo: String? {
        didSet {
            relayoutCellTitleLabel()
            additionalInfoLabel.text = additionalInfo
            additionalInfoLabel.isHidden = false
        }
    }
    
    private var titleLableTopConstraint: NSLayoutConstraint?
    private var titleLableBottomConstraint: NSLayoutConstraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellTitleLabel()
        setupAdditionalInfoLabel()
        setupDefaultCellBackground()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Cell depending on its position
extension TrackerOptionsTableViewCell {
    func setupFirstCellInTableView() -> TrackerOptionsTableViewCell {
        selectBackgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 16
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        return self
    }
    
    func setupLastCellWithoutBottomSeparator(
        tableViewWidth: CGFloat
    ) -> TrackerOptionsTableViewCell {
        selectBackgroundView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 16
        self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        self.separatorInset = UIEdgeInsets(
            top: 0,
            left: tableViewWidth + 1,
            bottom: 0,
            right: 0)
        return self
    }
    
    func setupSingleCellInTableView(
        tableViewWidth: CGFloat
    ) -> TrackerOptionsTableViewCell {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 16
        self.separatorInset = UIEdgeInsets(
            top: 0,
            left: tableViewWidth + 1,
            bottom: 0,
            right: 0)
        return self
    }
}

// MARK: Setup Views
private extension TrackerOptionsTableViewCell {
    func setupCellTitleLabel() {
        contentView.addSubview(cellTitleLabel)
        cellTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLableTopConstraint = NSLayoutConstraint(
            item: cellTitleLabel,
            attribute: .top,
            relatedBy: .equal,
            toItem: contentView,
            attribute: .top,
            multiplier: 1,
            constant: 26)
        
        titleLableBottomConstraint = NSLayoutConstraint(
            item: cellTitleLabel,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: contentView,
            attribute: .bottom,
            multiplier: 1,
            constant: -25)
        
        guard
            let titleLableTopConstraint = titleLableTopConstraint,
            let titleLableBottomConstraint = titleLableBottomConstraint
        else { return }
        
        NSLayoutConstraint.activate([
            cellTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cellTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -56),
            titleLableTopConstraint,
            titleLableBottomConstraint
        ])
        
        cellTitleLabel.textColor = .trackerBlackDay
        cellTitleLabel.font = .systemFont(ofSize: 17)
    }
    
    func setupAdditionalInfoLabel() {
        contentView.addSubview(additionalInfoLabel)
        additionalInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            additionalInfoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            additionalInfoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -56),
            additionalInfoLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 39),
            additionalInfoLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14)
        ])
        
        additionalInfoLabel.font = .systemFont(ofSize: 17)
        additionalInfoLabel.textColor = .trackerGray
        additionalInfoLabel.isHidden = true
    }
    
    func setupDefaultCellBackground() {
        backgroundColor = .trackerBackgroundDay
        selectedBackgroundView = selectBackgroundView
    }
}

private extension TrackerOptionsTableViewCell {
    func relayoutCellTitleLabel() {
        titleLableTopConstraint?.constant = 15
        titleLableBottomConstraint?.constant = -38
        layoutIfNeeded()
    }
}
