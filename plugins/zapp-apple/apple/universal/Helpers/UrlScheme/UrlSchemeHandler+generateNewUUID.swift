//
//  UrlSchemeHandler+generateNewUUID.swift
//  ZappApple
//
//  Created by Alex Zchut on 26/02/2020.
//

import Foundation
import ZappCore

extension UrlSchemeHandler {
    class func handleUUIDregeneration(with rootViewController: RootController?) -> Bool {
        let title = "Do you want to regenerate UUID?"
        let description = "New UUID will replace the old one and the app will be completely reloaded"
        let yesTitle = "Yes"
        let noTitle = "No"

        let alert = UIAlertController(title: title,
                                      message: description,
                                      preferredStyle: .alert)

        let yesButton = UIAlertAction(title: yesTitle,
                                         style: .destructive,
                                         handler: { _ in
                                            UUIDManager.regenerateUUID()
                                            rootViewController?.reloadApplication()
        })

        let noButton = UIAlertAction(title: noTitle,
                                         style: .default,
                                         handler: { _ in
                                            alert.dismiss(animated: true, completion: {
                                                rootViewController?.makeInterfaceLayerAsRootViewContoroller()
                                            })
        })

        alert.addAction(yesButton)
        alert.addAction(noButton)

        rootViewController?.makeSplashAsRootViewContoroller()
        rootViewController?.splashViewController?.present(alert,
                                                          animated: true,
                                                          completion: nil)

        return true
    }
}
