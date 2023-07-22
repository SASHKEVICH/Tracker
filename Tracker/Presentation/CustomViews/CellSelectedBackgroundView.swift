//
//  CellSelectBackgroundView.swift
//  Tracker
//
//  Created by Александр Бекренев on 20.06.2023.
//

import UIKit

final class CellSelectBackgroundView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .Static.lightGray
        self.layer.cornerRadius = 16
        self.layer.masksToBounds = true
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
