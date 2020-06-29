//
//  LoadingStateMachineDataSource.swift
//  ZappApple
//
//  Created by Anton Kononenko on 11/14/18.
//  Copyright © 2018 Anton Kononenko. All rights reserved.
//

import Foundation

public protocol LoadingStateMachineDataSource {
    func stateMachineFinishedWork(with state:LoadingStateTypes)
}
