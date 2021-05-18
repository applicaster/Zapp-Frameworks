//
//  UILabel+Extras.swift
//  CopaAmericaStatsScreenPluginDEMO
//
//  Created by Jesus De Meyer on 5/31/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import UIKit

extension UILabel {
    func useRegularFont() {
        let point = self.font.pointSize
        
        if let font = UIFont(name: "AvenirNextCondensed-Regular", size: point) {
            self.font = font
        }
    }
    
    func useBoldFont() {
        let point = self.font.pointSize
        
        if let font = UIFont(name: "AvenirNextCondensed-DemiBold", size: point) {
            self.font = font
        }
    }
    
    func useMediumBoldFont() {
        let point = self.font.pointSize
        
        if let font = UIFont(name: "AvenirNextCondensed-Medium", size: point) {
            self.font = font
        }
    }
}
