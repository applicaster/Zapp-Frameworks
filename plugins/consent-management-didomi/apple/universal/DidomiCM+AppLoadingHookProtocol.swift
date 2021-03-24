//
//  DidomiCM+AppLoadingHookProtocol.swift
//  ConsentManagementDidomi
//
//  Created by Alex Zchut on 24/03/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import Didomi
import Foundation
import ZappCore

extension DidomiCM: AppLoadingHookProtocol {
    public func executeOnApplicationReady(displayViewController: UIViewController?, completion: (() -> Void)?) {
        guard let displayViewController = displayViewController else {
            completion?()
            return
        }
        
        Didomi.shared.setupUI(containerController: displayViewController)
        completion?()
    }
}
