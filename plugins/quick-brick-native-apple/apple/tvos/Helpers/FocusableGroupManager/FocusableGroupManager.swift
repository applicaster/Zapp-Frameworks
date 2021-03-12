//
//  FocusableGroupManager.swift
//  QuickBrickApple
//
//  Created by Anton Kononenko on 4/17/19.
//  Copyright © 2019 Anton Kononenko. All rights reserved.
//

import Foundation
import React

/// Storage for focusable groups view [GroupID:FocusableGroupViewInstance]
var focusableGroups:[String:FocusableGroupView] = [:]

/// Storage for focusable views [GroupID:[ViewID:FocusableViewIntance]]
var itemsGroups:[String:[String:FocusableView]] = [:]

/// Class control focusable group view with focusable items
class FocusableGroupManager {
    
    /// Register FocusableView at storage
    ///
    /// - Parameter item: FocusableView instance
    class func registerView(item:FocusableView) -> Bool {
        guard let itemId = item.itemId,
        let groupId = item.groupId else {
            return false
        }
        var newItemsGroup:[String:FocusableView] = [:]
        if let itemsGroup = itemsGroups[groupId] {
            newItemsGroup = itemsGroup
        }
        newItemsGroup[itemId] = item
        itemsGroups[groupId] = newItemsGroup
        notifyGroupView(groupID: groupId)
        return true
    }

    /// Register FocusableGroup at storage
    ///
    /// - Parameter item: FocusableGroup instance
    class func registerFocusableGroup(group:FocusableGroupView) -> Bool {
        var retVal = false

        if let id = group.itemId {
            focusableGroups[id] = group
            retVal = true
        }
        return retVal

    }
    
    /// Retrieve group by ID
    ///
    /// - Parameter groupID:  ID of the group
    /// - Returns: FocusableGroupView instance if registered into manager
    class func group(by groupID:String) -> FocusableGroupView? {
        guard let groupView = focusableGroups[groupID] else {
            return nil
        }
        return groupView
    }
    
    /// Retrieve All items that connected to Group
    ///
    /// - Parameter groupID: ID of the group
    /// - Returns: Dictionary in format [ViewID:FocusableViewIntance]
    class func itemsForGroup(by groupID:String) -> [String:FocusableView] {
        guard let groupViewsDict = itemsGroups[groupID] else {
            return [:]
        }
        return groupViewsDict
    }
    
    /// Notify group view that item relevant to it was updated
    ///
    /// - Parameter groupID: ID of the group
    class func notifyGroupView(groupID:String) {
        DispatchQueue.main.async {
            guard let groupView = focusableGroups[groupID] else {
                return
            }
            let groupItems = itemsForGroup(by: groupID)
            groupView.groupItemsUpdated(groupItems: groupItems)
        }
    }
    
    /// Retrieve FocusableView view instance
    ///
    /// - Parameters:
    ///   - groupId: Id of the group
    ///   - itemId: Id of the FocusableView to search
    /// - Returns: FocusableView instance if exist in searched group, otherwise nil
    class func item(byGroupId groupId:String,
                    andItemId itemId:String) -> FocusableView? {
        return itemsForGroup(by: groupId).first(where: {$0.key == itemId})?.value
    }
    
    
    /// Make focus item focusable if exists and registered
    ///
    /// - Parameters:
    ///   - groupId: Id of the group
    ///   - itemId: Id of the focusable item
    ///   - needsForceUpdate: if value is true after make item as preferred item focus, It will also request Focus Engine to focus immidiately
    ///   - completion: completion block in case need, that will be called when focusable item did focus
    class func updateFocus(_ groupId: String?, itemId: String?, needsForceUpdate:Bool = false, completion:((_ success:Bool) -> Void)? = nil) {
        DispatchQueue.main.async {
            
            if let groupId = groupId,
                let itemId = itemId,
                let groupView = focusableGroups[groupId],
                let viewToFocus = FocusableGroupManager.item(byGroupId: groupId,
                                                             andItemId: itemId) {
                groupView.updatePrefferedFocusEnv(with: viewToFocus)
                
                var rootView:UIView? = groupView
                while(rootView !== nil && rootView?.isReactRootView() == false) {
                    if let unwrapedRootView = rootView,
                        let superView = unwrapedRootView.superview {
                        rootView = superView
                    } else {
                        rootView = nil
                    }
                }
                
                if rootView == nil {
                    return
                }
                
                if let rootView = rootView,
                    let superView = rootView.superview as? RCTRootView {
                    superView.reactPreferredFocusedView = viewToFocus
                    if needsForceUpdate == true {
                        superView.setNeedsFocusUpdate()
                        superView.updateFocusIfNeeded()
                        var completionWasCalled = false
                        
                        // Timeout 2 seconds if did focus was not called by some reason, we are passing completion
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            if completionWasCalled == false {
                                completion?(false)
                                groupView.didFocusCallBack = nil
                            }
                        }
                        
                        groupView.didFocusCallBack = (completion:{
                            completionWasCalled = true
                            completion?(true)
                            
                        }, focusableItemId:itemId)
                    }
                }
            }
        }
    }
}

