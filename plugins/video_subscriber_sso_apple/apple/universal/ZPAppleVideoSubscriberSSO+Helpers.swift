//
//  ZPAppleVideoSubscriberSSO+Helpers.swift
//  ZappAppleVideoSubscriberSSO
//
//  Created by Alex Zchut on 26/07/2020.
//

extension ZPAppleVideoSubscriberSSO {
    func presentFailureAlert() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        let alert = UIAlertController(title: vsFailureAlertTitle,
                                      message: vsFailureAlertDescription,
                                      preferredStyle: .alert)

        let okButton = UIAlertAction(title: vsFailureAlertOkButtonTitle,
                                         style: .default,
                                         handler: { _ in
                                            alert.dismiss(animated: true, completion: nil)
        })
        
        let goToSettings = UIAlertAction(title: vsFailureAlertSettingButtonTitle,
                                         style: .default,
                                         handler: { _ in
                                            alert.dismiss(animated: true, completion: {
                                                if UIApplication.shared.canOpenURL(settingsUrl) {
                                                    UIApplication.shared.open(settingsUrl, completionHandler: nil)
                                                }
                                            })
        })

        alert.addAction(okButton)
        alert.addAction(goToSettings)

        UIApplication.shared.keyWindow?.rootViewController?.present(alert,
                                                          animated: true,
                                                          completion: nil)
    }
    
    func presentLogoutAlert() {
        var settingPath = ""
        #if os(tvOS)
            settingPath = "Settings > Users and Accounts > TV Provider > Sign Out"
        #elseif os(iOS)
            settingPath = "Settings > TV Provider > Sign Out"
        #endif
        let message = "The app was authenticated through Apple TV Provider Authenticaiton. \nTo Sign Out please navigate to the device Settings App. \n\(settingPath)"
        
        let alert = UIAlertController(title: "Sign Out",
                                      message: message,
                                      preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: vsFailureAlertOkButtonTitle,
                                         style: .default,
                                         handler: { _ in
                                            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(okButton)
        
        if #available(tvOS 13.0, iOS 13.0, *) {
            if let providerSettingsUrl = URL(string: self.tvProviderSettingsUrl) {
                let goToSettings = UIAlertAction(title: vsSignOutAlertSettingButtonTitle,
                                                 style: .default,
                                                 handler: { _ in
                       alert.dismiss(animated: true, completion: {
                           if UIApplication.shared.canOpenURL(providerSettingsUrl) {
                               UIApplication.shared.open(providerSettingsUrl, completionHandler: nil)
                           }
                       })
                })
                alert.addAction(goToSettings)
            }
        }

        UIApplication.shared.keyWindow?.rootViewController?.present(alert,
                                                          animated: true,
                                                          completion: nil)
    }
}
