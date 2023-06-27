//
//  UIColorMarshalling.swift
//  Tracker
//
//  Created by Александр Бекренев on 03.05.2023.
//

import UIKit

struct UIColorMarshalling {
    static func serilizeToHex(color: UIColor) -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let hexString = String(format: "#%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))

        return hexString
    }
    
    static func deserilizeFrom(hex: String) -> UIColor? {
        guard hex.hasPrefix("#") else {
            assertionFailure("string is not hex")
            return nil
        }
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)

        var rgbValue: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbValue)

        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0

        let color = UIColor(red: red, green: green, blue: blue, alpha: 1.0)

        return color
    }
}
