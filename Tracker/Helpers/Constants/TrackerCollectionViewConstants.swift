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
    
    private static var iPhoneXTrackerConfiguration: TrackerCollectionViewConstants {
        let insets = UIEdgeInsets(top: 12, left: 16, bottom: 0, right: 16)
        return TrackerCollectionViewConstants(
            collectionViewInsets: insets,
            horizontalCellSpacing: 9,
            verticalCellSpacing: 0)
    }
        
    private static var iPhoneSETrackerConfiguration: TrackerCollectionViewConstants {
        let insets = UIEdgeInsets(top: 12, left: 16, bottom: 0, right: 16)
        return TrackerCollectionViewConstants(
            collectionViewInsets: insets,
            horizontalCellSpacing: 10,
            verticalCellSpacing: 0)
    }
    
    private static var iPhoneXAddTrackerConfiguration: TrackerCollectionViewConstants {
        let insets = UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 19)
        return TrackerCollectionViewConstants(
            collectionViewInsets: insets,
            horizontalCellSpacing: 5,
            verticalCellSpacing: 0)
    }
    
    private static var iPhoneSEAddTrackerConfiguration: TrackerCollectionViewConstants {
        let insets = UIEdgeInsets(top: 24, left: 16, bottom: 24, right: 16)
        return TrackerCollectionViewConstants(
            collectionViewInsets: insets,
            horizontalCellSpacing: 0,
            verticalCellSpacing: 0)
    }
}

extension TrackerCollectionViewConstants {
    static var trackersCollectionConfiguration: TrackerCollectionViewConstants {
        let currentDeviceType = Device.type
        switch currentDeviceType {
        case .iphoneSE:
            return iPhoneSETrackerConfiguration
        default:
            return iPhoneXTrackerConfiguration
        }
    }
    
    static var addTrackerCollectionsConfiguration: TrackerCollectionViewConstants {
        let currentDeviceType = Device.type
        switch currentDeviceType {
        case .iphoneSE:
            return iPhoneSEAddTrackerConfiguration
        default:
            return iPhoneXAddTrackerConfiguration
        }
    }
}
