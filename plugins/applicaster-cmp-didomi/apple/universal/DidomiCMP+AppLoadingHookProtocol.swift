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
    public func executeOnLaunch(completion: (() -> Void)?) {
        DispatchQueue.main.async {
            guard let displayViewController = UIApplication.shared.keyWindow?.rootViewController else {
                self.logger?.infoLog(message: "Unable to present user consent")
                completion?()
                return
            }

            guard self.shouldPresentOnStartup == true else {
                self.logger?.infoLog(message: "User consent presentOnStartup is disabled")
                completion?()
                return
            }

            switch self.cmpStatus {
            case .undefined:
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.executeOnLaunch(completion: completion)
                }
            case .ready:
                guard Didomi.shared.shouldConsentBeCollected() else {
                    completion?()
                    return
                }

                self.presentationCompletion = completion
                Didomi.shared.setupUI(containerController: displayViewController)
            case .error:
                completion?()
            }
        }
    }
    
    public func executeAfterAppRootPresentation(displayViewController: UIViewController?, completion: (() -> Void)?) {
        self.saveParamsToSessionStorageIfExists()
        
        DispatchQueue.main.async {
            if let rootController = UIApplication.shared.keyWindow?.rootViewController {
                Didomi.shared.setupUI(containerController: rootController)
            }
        }
        
        completion?()
    }
}
