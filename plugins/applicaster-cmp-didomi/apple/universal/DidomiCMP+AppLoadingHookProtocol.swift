//
//  DidomiCMP+AppLoadingHookProtocol.swift
//  ConsentManagementDidomi
//
//  Created by Alex Zchut on 24/03/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import Didomi
import Foundation
import XrayLogger
import ZappCore

extension DidomiCMP: AppLoadingHookProtocol {
    public func executeAfterAppRootPresentation(displayViewController: UIViewController?, completion: (() -> Void)?) {
        DispatchQueue.main.async {
            guard let displayViewController = UIApplication.shared.delegate?.window??.rootViewController else {
                self.logger?.infoLog(message: "Unable to present user consent")
                completion?()
                return
            }

            guard self.shouldPresentOnStartup == true else {
                self.logger?.infoLog(message: "User consent presentOnStartup is disabled")

                completion?()
                return
            }

            Didomi.shared.setupUI(containerController: displayViewController)
            completion?()
        }
    }
}
