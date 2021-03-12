//
//  ParallaxViewDelegate.swift
//  QuickBrickApple
//
//  Created by Anton Kononenko on 5/4/19.
//  Copyright © 2019 Anton Kononenko. All rights reserved.
//

import Foundation

/// This protocol conform delegate pattern for the ParallaxView
public protocol ParallaxViewDelegate:class {
    
    /// Delegate to responder that ParallaxView instance will focus
    ///
    /// - Parameter parallaxView: instance of ParallaxView
    func parallaxViewWillFocus(_ parallaxView: ParallaxView)
    
    /// Delegate to responder that ParallaxView instance did focus
    ///
    /// - Parameter parallaxView: instance of ParallaxView
    func parallaxViewDidFocus(_ parallaxView: ParallaxView)
    
    /// Delegate to responder that ParallaxView instance will unfocus
    ///
    /// - Parameter parallaxView: instance of ParallaxView
    func parallaxViewWillUnfocus(_ parallaxView: ParallaxView)
    
    /// Delegate to responder that ParallaxView instance did unfocus
    ///
    /// - Parameter parallaxView: instance of ParallaxView
    func parallaxViewDidUnfocus(_ parallaxView: ParallaxView)
    
    /// Delegate to responder that ParallaxView instance will select
    ///
    /// - Parameter parallaxView: instance of ParallaxView
    func parallaxViewWillSelected(_ parallaxView: ParallaxView)
    
    /// Delegate to responder that ParallaxView instance did select
    ///
    /// - Parameter parallaxView: instance of ParallaxView
    func parallaxViewDidSelected(_ parallaxView: ParallaxView)
}
