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
}
