//
//  TrackerCollectionViewConstants.swift
//  Tracker
//
//  Created by Александр Бекренев on 04.04.2023.
//

import UIKit

struct TrackerCollectionViewConstants {
    let collectionViewInsets: UIEdgeInsets
    let horizontalCellSpacing: CGFloat
    let verticalCellSpacing: CGFloat
    
	static var trackersCollectionConfiguration: TrackerCollectionViewConstants {
		let currentDeviceType = Device.model
		switch currentDeviceType {
		case .iphoneSE, .iphoneSE2, .iphoneSE3, .iphone7, .iphone7plus, .iphone8, .iphone8plus:
			return iPhoneSETrackerConfiguration
		default:
			return iPhoneXTrackerConfiguration
		}
	}

	static var addTrackerCollectionsConfiguration: TrackerCollectionViewConstants {
		let currentDeviceType = Device.model
		switch currentDeviceType {
		case .iphoneSE, .iphoneSE2, .iphoneSE3, .iphone7, .iphone7plus, .iphone8, .iphone8plus:
			return iPhoneSEAddTrackerConfiguration
		default:
			return iPhoneXAddTrackerConfiguration
		}
	}
}

private extension TrackerCollectionViewConstants {
	static var iPhoneXTrackerConfiguration: TrackerCollectionViewConstants {
		let insets = UIEdgeInsets(top: 12, left: 16, bottom: 0, right: 16)
		return TrackerCollectionViewConstants(
			collectionViewInsets: insets,
			horizontalCellSpacing: 9,
			verticalCellSpacing: 0)
	}

	static var iPhoneSETrackerConfiguration: TrackerCollectionViewConstants {
		let insets = UIEdgeInsets(top: 12, left: 16, bottom: 0, right: 16)
		return TrackerCollectionViewConstants(
			collectionViewInsets: insets,
			horizontalCellSpacing: 10,
			verticalCellSpacing: 0)
	}

	static var iPhoneXAddTrackerConfiguration: TrackerCollectionViewConstants {
		let insets = UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 19)
		return TrackerCollectionViewConstants(
			collectionViewInsets: insets,
			horizontalCellSpacing: 5,
			verticalCellSpacing: 0)
	}

	static var iPhoneSEAddTrackerConfiguration: TrackerCollectionViewConstants {
		let insets = UIEdgeInsets(top: 24, left: 16, bottom: 24, right: 16)
		return TrackerCollectionViewConstants(
			collectionViewInsets: insets,
			horizontalCellSpacing: 0,
			verticalCellSpacing: 0)
	}
}
