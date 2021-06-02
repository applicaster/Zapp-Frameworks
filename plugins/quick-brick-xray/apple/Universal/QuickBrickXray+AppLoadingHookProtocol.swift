//
//  QuickBrickXray+AppLoadingHookProtocol.swift
//  QuickBrickXray
//
//  Created by Alex Zchut on 02/06/2021.
//

import Foundation
import ZappCore

extension QuickBrickXray: AppLoadingHookProtocol {
    public func executeAfterAppRootPresentation(displayViewController: UIViewController?, completion: (() -> Void)?) {
        prepareXRayFloatingButton()

        completion?()
    }
}
