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
    
    private static var iPhoneXConfiguration: TrackerCollectionViewConstants {
        let insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return TrackerCollectionViewConstants(
            collectionViewInsets: insets,
            horizontalCellSpacing: 9,
            verticalCellSpacing: 0)
    }
        
    private static var iPhoneSEConfiguration: TrackerCollectionViewConstants {
        let insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return TrackerCollectionViewConstants(
            collectionViewInsets: insets,
            horizontalCellSpacing: 10,
            verticalCellSpacing: 0)
    }
    
    static var configuration: TrackerCollectionViewConstants {
        let currentDeviceType = Device.type
        switch currentDeviceType {
        case .iphoneSE:
            return iPhoneSEConfiguration
        default:
            return iPhoneXConfiguration
        }
    }
}
