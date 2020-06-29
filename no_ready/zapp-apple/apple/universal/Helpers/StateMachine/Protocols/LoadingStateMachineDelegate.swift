//
//  LoadingStateMachineDelegate.swift
//  ZappApple
//
//  Created by Anton Kononenko on 11/14/18.
//  Copyright © 2018 Anton Kononenko. All rights reserved.
//

import Foundation

public protocol LoadingStateMachineDelegate {
    func stateDidUpdated(state:LoadingState)
    func state(by stateId:String) -> LoadingState?
}
