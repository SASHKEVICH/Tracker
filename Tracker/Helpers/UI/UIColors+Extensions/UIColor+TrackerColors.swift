//
//  UIColor+Extensions.swift
//  Tracker
//
//  Created by Александр Бекренев on 31.03.2023.
//

import UIKit

extension UIColor {
    static var trackerBackgroundDay: UIColor {
        UIColor(named: "TrackerBackgroundDay") ?? .red
    }
    
    static var trackerWhiteDay: UIColor {
        UIColor(named: "TrackerWhiteDay") ?? .red
    }
    
    static var trackerBlackDay: UIColor {
        UIColor(named: "TrackerBlackDay") ?? .red
    }
    
    static var trackerBlue: UIColor {
        UIColor(named: "TrackerBlue") ?? .red
    }
    
    static var trackerGray: UIColor {
        UIColor(named: "TrackerGray") ?? .red
    }
    
    static var trackerRed: UIColor {
        UIColor(named: "TrackerRed") ?? .blue
    }
    
    static var trackerSwitchBackgroundColor: UIColor {
        UIColor(named: "TrackerSwitchBackgroundColor") ?? .red
    }
    
    static var trackerLightGray: UIColor {
        UIColor(named: "TrackerLightGray") ?? .red
    }
}
