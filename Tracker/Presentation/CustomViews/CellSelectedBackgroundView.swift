//
//  CellSelectBackgroundView.swift
//  Tracker
//
//  Created by Александр Бекренев on 20.06.2023.
//

import UIKit

final class CellSelectBackgroundView: UIView {
	override func draw(_ rect: CGRect) {
		super.draw(rect)
		
		backgroundColor = .trackerLightGray
		layer.cornerRadius = 16
		layer.masksToBounds = true
	}
}
