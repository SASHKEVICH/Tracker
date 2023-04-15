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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellTitleLabel()
        setupDefaultCellBackground()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

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

private extension TrackerOptionsTableViewCell {
    func setupCellTitleLabel() {
        contentView.addSubview(cellTitleLabel)
        cellTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cellTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cellTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -41),
            cellTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 26),
            cellTitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -25)
        ])
        
        cellTitleLabel.textColor = .trackerBlackDay
        cellTitleLabel.font = .systemFont(ofSize: 17)
    }
    
    func setupDefaultCellBackground() {
        backgroundColor = .trackerBackgroundDay
        selectedBackgroundView = selectBackgroundView
    }
}
