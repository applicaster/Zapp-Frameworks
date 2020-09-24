//
//  UIColor+Additions.swift
//  ZappApple
//
//  Created by Anton Kononenko on 10/15/19.
//  Copyright © 2019 Applicaster LTD. All rights reserved.
//

import UIKit

extension UIColor {
    public convenience init?(ARGBHex: String) {
        let r, g, b, a: CGFloat
        var hexColor = ARGBHex
        
        if ARGBHex.hasPrefix("#") {
            let start = ARGBHex.index(ARGBHex.startIndex, offsetBy: 1)
            hexColor = String(ARGBHex[start...])
        }
        
        if hexColor.count == 8 {
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0

            if scanner.scanHexInt64(&hexNumber) {
                a = CGFloat((hexNumber & 0xFF000000) >> 24) / 255
                r = CGFloat((hexNumber & 0x00FF0000) >> 16) / 255
                g = CGFloat((hexNumber & 0x0000FF00) >> 8) / 255
                b = CGFloat(hexNumber & 0x000000FF) / 255

                self.init(red: r, green: g, blue: b, alpha: a)
                return
            }
        }

        return nil
    }
    
    public convenience init?(RGBAHex: String) {
        let r, g, b, a: CGFloat
        var hexColor = RGBAHex
        
        if RGBAHex.hasPrefix("#") {
            let start = RGBAHex.index(RGBAHex.startIndex, offsetBy: 1)
            hexColor = String(RGBAHex[start...])
        }
        
        if hexColor.count == 8 {
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0

            if scanner.scanHexInt64(&hexNumber) {
                r = CGFloat((hexNumber & 0xFF000000) >> 24) / 255
                g = CGFloat((hexNumber & 0x00FF0000) >> 16) / 255
                b = CGFloat((hexNumber & 0x0000FF00) >> 8) / 255
                a = CGFloat(hexNumber & 0x000000FF) / 255

                self.init(red: r, green: g, blue: b, alpha: a)
                return
            }
        }

        return nil
    }
}
