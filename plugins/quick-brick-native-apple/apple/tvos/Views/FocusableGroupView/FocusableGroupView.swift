//
//  FocusableGroupView.swift
//  QuickBrickApple
//
//  Created by Anton Kononenko on 3/1/19.
//  Copyright © 2019 Kononenko. All rights reserved.
//

import Foundation
import UIKit
import React

/// Focusable  Group View that implements UIFocusGuide instance that catches focus event
public class FocusableGroupView:RCTTVView {
    
    /// Completion that will be used when focus manager forcing to update focusable group
    var didFocusCallBack:(completion:(() -> ()), focusableItemId:String)?
    
    /// This parameter blocks focus behavior without user interaction, it is used to prevent fast jumps between items
    @objc public var isManuallyBlockingFocusValue: NSNumber?
    
    private var isManuallyBlockingFocus: Bool = false
    
    /// Notify React-Native environment that Focus Did Update
    @objc public var onDidUpdateFocus:RCTBubblingEventBlock?
    
    /// Notify React-Native environment that Focus Will Update
    @objc public var onWillUpdateFocus:RCTBubblingEventBlock?
    
    /// Define if focus enabled for current view
    @objc public var isFocusDisabled:Bool = false
    
    /// Current group will try to find initial index id in groups
    @objc public var dependantGroupIds:[String]?
    
    /// Check if preferred focus has to be reset to initial value, after group becomes inactive
    @objc public var resetFocusToInitialValue:Bool = false
    
    /// ID of the item that must be focused as init focus
    @objc public var initialItemId:String?
    
    /// ID of the Connected GroupView provided by React-Native env
    @objc public var itemId:String? {
        didSet{
            if itemId != oldValue {
                _ = FocusableGroupManager.registerFocusableGroup(group: self)
            }
        }
    }
    
    /// ID of the parent group, if relevant
    @objc public var groupId:String?
    
    /// If this variable not nil it overrides default preffered focus environment
    var customPrefferedFocusEnvironment:[UIFocusEnvironment]? {
        didSet {
            var rootView:UIView? = self

            while(rootView?.superview != nil) {
                if let unwrapedRootView = rootView,
                    let superView = unwrapedRootView.superview {
                    rootView = superView
                    if let superFocusGroup = rootView as? FocusableGroupView {
                        if let newFocusData = customPrefferedFocusEnvironment as? [FocusableView],
                            let superFocusGroupFocusEnvironment = superFocusGroup.customPrefferedFocusEnvironment as? [FocusableView] {
                            let groupIdsToStay = newFocusData.map({$0.groupId})
                            let filteredGroups = superFocusGroupFocusEnvironment.filter { !groupIdsToStay.contains($0.groupId) }
                            superFocusGroup.customPrefferedFocusEnvironment = filteredGroups + newFocusData
                        } else {
                            superFocusGroup.customPrefferedFocusEnvironment = customPrefferedFocusEnvironment
                        }
                    }
                }
            }
       
        }
    }
    /// Check if group has an initial focus
    /// Note: In case Initial init when app start not calling shouldFocusUpdate
    var isGroupWasFocusedByUser = false

    /// View connected to GroupView was updated
    ///
    /// - Parameter groupItems: dictionary connected to group view
    public func groupItemsUpdated(groupItems:[String:FocusableView]) {
        guard
            self.isGroupWasFocusedByUser == false,
            let initialItemId = initialItemId,
            let initialView = groupItems[initialItemId] else {
                return
        }
        
        let focusedView = customPrefferedFocusEnvironment?.first as? UIView
        if focusedView != initialView || focusedView == nil {
            customPrefferedFocusEnvironment = [initialView]
        }
    }
    
    /// Reset focus to initial state if needed
    ///
    /// - Parameter nextFocusedItem: next item that should be focused
    /// - Returns: true if reser succeed
    func resetFocusPrefferedEnvironmentIfNeeded(nextFocusedItem: UIFocusItem?) -> Bool {
        var retVal = false
        guard let nextFocusedItem = nextFocusedItem else {
            return retVal
        }
        
        if focusItemIsDescendant(nextFocuseItem: nextFocusedItem) == false {
            if resetFocusToInitialValue,
                let initialItemId = initialItemId {
                if self.tryTakePrefferedViewFromDependantGroups() == false {
                    if let groupId = groupId,
                        let initialItemView = FocusableGroupManager.item(byGroupId: groupId,
                                                                         andItemId: initialItemId) {
                        self.customPrefferedFocusEnvironment = [initialItemView]
                        retVal = true
                    }
                } else {
                    retVal = true
                }
            }
        }
        return retVal
    }
    
    /// Try to focus on preffered item from another group
    ///
    /// - Returns: true if can focus otherwise false
    func tryTakePrefferedViewFromDependantGroups() -> Bool {
        guard let initialItemId = initialItemId,
            let dependantGroupIds = dependantGroupIds,
            
            let firstGroupId = dependantGroupIds.first,
            let initialView = FocusableGroupManager.item(byGroupId: firstGroupId,
                                                         andItemId: initialItemId) else {
                                                            return false
        }

        customPrefferedFocusEnvironment = [initialView]
        
        return true
    }
    
    /// Focus guide that will catch the focus of the groups
    var focusGuide = UIFocusGuide()
    
    /// Manager that connects View instance to FocusableGroupViewModule
    var manager:FocusableGroupViewModule?
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFocus()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupFocus()
    }
    
    /// Update customPrefferedFocusEnvironment
    ///
    /// - Parameter view: view instance that should be preffered
    func updatePrefferedFocusEnv(with view:FocusableView) {
        customPrefferedFocusEnvironment = [view]
    }
    
    /// Setup Focus Guide for use
    func setupFocus() {
        self.addLayoutGuide(focusGuide)
        
        focusGuide.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        focusGuide.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        focusGuide.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        focusGuide.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true

    }
    
    /// Send update focus event to Reactnative
    ///
    /// - Parameter context: Update UIFocusUpdateContext instance
    func sendUpdateFocusEventToReactNative(bubbleEventBlock:RCTBubblingEventBlock?, context:UIFocusUpdateContext) {
        guard let bubbleEventBlock = bubbleEventBlock  else {
            return
        }
        let focusHeading = focusHeadingToString(focusHeading: context.focusHeading)
        var params:[String:Any] = [GroupViewUpdateEvents.focusHeading:focusHeading];
        
        params[GroupViewUpdateEvents.isFocusingByUser] = focusHeading != FocusHeadingTextValues.manualUpdate
        
        params[GroupViewUpdateEvents.previouslyFocusedItem] = dataForFocusItem(focusItem: context.previouslyFocusedView)
        params[GroupViewUpdateEvents.nextFocusedItem] = dataForFocusItem(focusItem: context.nextFocusedView)
        params[GroupViewUpdateEvents.prefferedFocusEnvironment] = dataForFocusItem(focusItem: customPrefferedFocusEnvironment?.first)
        params[GroupViewUpdateEvents.groupId] = groupId

        if let focusableView = context.nextFocusedItem as? FocusableView {
            params[GroupViewUpdateEvents.itemId] = focusableView.itemId
        }
        
        if focusItemIsDescendant(nextFocuseItem: context.nextFocusedItem) {
            params[GroupViewUpdateEvents.isActive] = true
            
        } else {
            params[GroupViewUpdateEvents.isActive] = false
            isFocusDisabled = false
            if resetFocusToInitialValue,
                let initialItemId = initialItemId{
                if let groupId = groupId {
                    let groupItems = FocusableGroupManager.itemsForGroup(by: groupId)
                    if let initialItemView = groupItems[initialItemId] {
                        self.customPrefferedFocusEnvironment = [initialItemView]
                    }
                }
            }
        }
        params[GroupViewUpdateEvents.isFocusDisabled] = isFocusDisabled

        bubbleEventBlock(params)
    }
 
    /// Data for Focus Item that will be passed to React-Native env
    ///
    /// - Parameter focusItem: focu item instance
    /// - Returns: dictionary instance in case data exists, otherwise nil
    func dataForFocusItem(focusItem: Any?) -> [String:Any]? {
        var retVal = [String:Any]()
        if let focusedView = focusItem as? RCTTVView {
            
            retVal[FocusItemDataKeys.describingView] = String(describing: focusedView)
            if let reactTag = focusedView.reactTag?.stringValue {
                retVal[FocusItemDataKeys.reactTag] = reactTag
            }
            retVal[FocusItemDataKeys.isDescendant] = focusedView.isDescendant(of: self)
        }
        return retVal.keys.count == 0 ? nil : retVal
    }
    
    /// Update preffered Focus View for focuse guide if next focuasable view is part of this focus guide
    ///
    /// - Parameter nextFocuseItem: next focus item instance
    func updatePreferredFocusView(nextFocuseItem: Any?) {
        guard let nextFocusView = nextFocuseItem as? UIView,
            nextFocusView.isDescendant(of: self) else {
            return
        }

        customPrefferedFocusEnvironment = [nextFocusView]
    }
    
    /// Checks if next focus item is part of the current group
    ///
    /// - Parameter nextFocuseItem: next item to focus
    /// - Returns: true if next focus item part of this group instance
    func focusItemIsDescendant(nextFocuseItem:Any?) -> Bool {
        guard let nextFocusView = nextFocuseItem as? UIView,
            nextFocusView.isDescendant(of: self) else {
                return false
        }
        return true
    }
    
    /// Mapping focus enum to readable string
    ///
    /// - Parameter focusHeading: UIFocusHeading enum
    /// - Returns: Readable string from enum
    func focusHeadingToString(focusHeading:UIFocusHeading) -> String {
        switch focusHeading {
        case UIFocusHeading.up:
            return FocusHeadingTextValues.up
        case UIFocusHeading.down:
            return FocusHeadingTextValues.down
        case UIFocusHeading.left:
            return FocusHeadingTextValues.left
        case UIFocusHeading.right:
            return FocusHeadingTextValues.right
        case UIFocusHeading.next:
            return FocusHeadingTextValues.next
        case UIFocusHeading.previous:
            return FocusHeadingTextValues.previous
        default:
            return FocusHeadingTextValues.manualUpdate
        }
    }
    
    /// Force manually focus update
    func manuallyBlockFocus() {
        if let isManuallyBlockingFocusValue = isManuallyBlockingFocusValue {
            isManuallyBlockingFocus = true
            let delay = DispatchTime.now() + DispatchTimeInterval.milliseconds(Int(isManuallyBlockingFocusValue.floatValue * 1000))

            DispatchQueue.main.asyncAfter(deadline: delay)  { [weak self] in
                self?.isManuallyBlockingFocus = false
            }
        }
    }
    
    //MARK: Focus Engine
    
    public override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if let customPrefferedFocusEnvironment = customPrefferedFocusEnvironment {
            return customPrefferedFocusEnvironment
        }
        return super.preferredFocusEnvironments
    }
    
    public override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
        guard isFocusDisabled == false,
            isManuallyBlockingFocus == false
            else {
//                 Ignoring focus events that blocks by native side for purpose (maybe changed if future)
                if isManuallyBlockingFocus == false {
                
                    sendUpdateFocusEventToReactNative(bubbleEventBlock:onWillUpdateFocus,
                                                      context: context)
                }
                return false
        }

        isGroupWasFocusedByUser = true
   
        if resetFocusPrefferedEnvironmentIfNeeded(nextFocusedItem: context.nextFocusedItem) == false {
            updatePreferredFocusView(nextFocuseItem: context.nextFocusedItem)
        }

        sendUpdateFocusEventToReactNative(bubbleEventBlock:onWillUpdateFocus,
                                          context: context)

        if focusItemIsDescendant(nextFocuseItem: context.nextFocusedItem) == false {
            isFocusDisabled = false
        }
        return true
    }

 
    override public func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        manuallyBlockFocus()
        tryDidFocusCallCallback(context: context)
        sendUpdateFocusEventToReactNative(bubbleEventBlock:onDidUpdateFocus,
                                          context: context)
    }
    
    
    /// Try to send a callback in case focus manager request callback during force focus update
    ///
    /// - Parameter context: An instance of UIFocusUpdateContext containing metadata of the focus related update.
    func tryDidFocusCallCallback(context: UIFocusUpdateContext) {
        guard let callbackData = didFocusCallBack,
            let fousedView = context.nextFocusedView as? FocusableView,
            let itemId = fousedView.itemId else {
                return
        }
        
        let completion = callbackData.completion
        let focusableItemId = callbackData.focusableItemId
        if itemId == focusableItemId {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                completion()
            }
        }
        didFocusCallBack = nil
    }
}
