//
//  FocusableChildView.swift
//  QuickBrickApple
//
//  Created by Anton Kononenko on 4/17/19.
//  Copyright © 2019 Anton Kononenko. All rights reserved.
//

import Foundation
import UIKit
import React

/// RCTTVView subclass that has api how to conects to FocusableGroup
public class FocusableView: ParallaxView {

    @objc public var onViewFocus:RCTBubblingEventBlock?
    @objc public var onViewPress:RCTBubblingEventBlock?
    @objc public var onViewBlur:RCTBubblingEventBlock?
    @objc public var isParallaxDisabled:Bool = false {
        didSet {
            parallaxEffectOptions.parallaxMotionEffect.isDisabled = isParallaxDisabled
        }
    }

    @objc public var isPressDisabled:Bool = false {
        didSet {
            isPressActionDisabled = isPressDisabled
        }
    }
    
    /// Define if view can become focused
    @objc open var focusable = true
    
    @objc public var preferredFocus:Bool = false {
        didSet {
            guard preferredFocus else {
                return
            }
            DispatchQueue.main.async { [weak self] in
                if let groupId = self?.groupId,
                    let focusableGroup = focusableGroups[groupId] {
                    //Update Prefered focus view in group
                    focusableGroup.updatePrefferedFocusEnv(with: self!)
                    
                }
            }
        }
    }
    /// Define if this view is preffered tv focused View
    @objc public var forceFocus:Bool = false {
        
        didSet {
            guard forceFocus else {
                return
            }
            DispatchQueue.main.async { [weak self] in
                            FocusableGroupManager.updateFocus(self?.groupId,
                                                              itemId: self?.itemId,
                                                              needsForceUpdate: true,
                                                              completion: nil)
            }
        }
    }
    
    public override var canBecomeFocused: Bool {
        return focusable
    }
    
    /// Define if view was registered
    var isViewRegistered:Bool = false

    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    
    /// Initialize component
    func initialize() {
        delegate = self
    }
    
    /// ID of the View provided by React-Native env
    @objc public var itemId:String? {
        didSet {
            registerView()
        }
    }
    
    /// ID of the View provided by React-Native env
    @objc public var groupId:String? {
        didSet {
            registerView()
        }
    }
    
    /// Register View in FocusableGroupManager
    func registerView() {
        guard itemId != nil,
            groupId != nil,
            isViewRegistered == false,
            FocusableGroupManager.registerView(item: self) else {
                return
        }
        
        self.isViewRegistered = true
    }
}

