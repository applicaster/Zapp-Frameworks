//
//  DidomiCMP+AppLoadingHookProtocol.swift
//  ConsentManagementDidomi
//
//  Created by Alex Zchut on 24/03/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import Didomi
import Foundation
import ZappCore

extension DidomiCMP: AppLoadingHookProtocol {
    public func executeAfterAppRootPresentation(displayViewController: UIViewController?, completion: (() -> Void)?) {
        DispatchQueue.main.async {
            guard let displayViewController = UIApplication.shared.delegate?.window??.rootViewController,
                  self.shouldPresentOnStartup == true else {
                completion?()
                return
            }

            Didomi.shared.setupUI(containerController: displayViewController)
            completion?()
        }
    }
}
