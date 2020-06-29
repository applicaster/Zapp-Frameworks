//
//  LoadingStateConst.swift
//  ZappApple
//
//  Created by Anton Kononenko on 1/31/19.
//  Copyright © 2019 Anton Kononenko. All rights reserved.
//

import Foundation

public typealias StateCallBack = () -> Void
public typealias StateHandler = (_ successHandler: @escaping StateCallBack,
    _ failHandler:@escaping StateCallBack) -> Void

public enum LoadingStateTypes {
    case initial
    case loading
    case success
    case failed
    
    public func isStateFinishedTask() -> Bool {
        return self == .success || self == .failed
    }
    
    public func toString() -> String {
        switch self {
        case .initial:
            return "initial"
        case .loading:
            return "loading"
        case .success:
            return "success"
        case .failed:
            return "failed"
        }
    }
}
