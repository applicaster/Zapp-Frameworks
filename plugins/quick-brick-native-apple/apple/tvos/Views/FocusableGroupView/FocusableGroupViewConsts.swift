//
//  FocusableGroupViewConsts.swift
//  QuickBrickApple
//
//  Created by Anton Kononenko on 4/19/19.
//  Copyright © 2019 Anton Kononenko. All rights reserved.
//

/// Defines Keys that will be passed for focus event heading
public struct FocusHeadingTextValues {
    static let up           = "Up"
    static let down         = "Down"
    static let left         = "Left"
    static let right        = "Right"
    static let next         = "Next"
    static let previous     = "Previous"
    static let manualUpdate = "Posible manual update or initial focus by tvOS"
}

/// Group view events that will be passed to React-Native env
public struct GroupViewUpdateEvents {
    static let focusHeading              = "focusHeading"
    static let previouslyFocusedItem     = "previouslyFocusedItem"
    static let nextFocusedItem           = "nextFocusedItem"
    static let prefferedFocusEnvironment = "prefferedFocusEnvironment"
    static let groupId                   = "groupId"
    static let itemId                    = "itemId"
    static let isActive                  = "isActive"
    static let isFocusDisabled           = "isFocusDisabled"
    static let isFocusingByUser          = "isFocusingByUser"
}

/// Keys that will be passed to React-Native env for GroupViewUpdateEvents with `previouslyFocusedItem` and `nextFocusedItem`
public struct FocusItemDataKeys {
    static let describingView = "describingView"
    static let reactTag       = "reactTag"
    static let isDescendant   = "isDescendant"
}
