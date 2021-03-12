//
//  FocusableView+ParallaxViewDelegate.swift
//  QuickBrickApple
//
//  Created by Anton Kononenko on 5/4/19.
//  Copyright © 2019 Anton Kononenko. All rights reserved.
//

import Foundation

extension FocusableView:ParallaxViewDelegate {
    public func parallaxViewWillFocus(_ parallaxView: ParallaxView) {
        guard let onFocus = onViewFocus else {
            return
        }
        onFocus(eventData())
    }
    
    public func parallaxViewDidFocus(_ parallaxView: ParallaxView) {

    }
    
    public func parallaxViewWillUnfocus(_ parallaxView: ParallaxView) {
        guard let onBlur = onViewBlur else {
            return
        }
        onBlur(eventData())
    }
    
    public func parallaxViewDidUnfocus(_ parallaxView: ParallaxView) {
        
    }
    
    public func parallaxViewWillSelected(_ parallaxView: ParallaxView) {
        
    }
    
    public func parallaxViewDidSelected(_ parallaxView: ParallaxView) {
        guard let onPress = onViewPress else {
            return
        }
        onPress(eventData())
    }
    
    func eventData() -> [String:Any] {
        var retVal:[String:Any] = [:]
        retVal["tag"] = reactTag
        retVal["itemID"] = itemId
        return retVal
    }
}
