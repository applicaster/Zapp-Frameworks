//
//  AppDelegateExtandable.swift
//  ZappApple
//
//  Created by Anton Kononenko on 01/19/21.
//  Copyright © 2021 Anton Kononenko. All rights reserved.
//
import Foundation
import ZappCore
import react_native_app_auth

var _authorizationFlowManagerDelegate: RNAppAuthAuthorizationFlowManagerDelegate?
extension AppDelegateExtandable:RNAppAuthAuthorizationFlowManager {
    public weak var authorizationFlowManagerDelegate: RNAppAuthAuthorizationFlowManagerDelegate? {
        get {
            _authorizationFlowManagerDelegate
        }
        set {
            _authorizationFlowManagerDelegate = newValue
        }
    }
}
