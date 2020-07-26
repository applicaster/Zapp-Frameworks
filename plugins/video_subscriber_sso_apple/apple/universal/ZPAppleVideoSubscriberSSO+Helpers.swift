//
//  ZPAppleVideoSubscriberSSO+Helpers.swift
//  ZappAppleVideoSubscriberSSO
//
//  Created by Alex Zchut on 26/07/2020.
//

extension ZPAppleVideoSubscriberSSO {
    func presentFailureAlert() {
        let alert = UIAlertController(title: vsFailureAlertTitle,
                                      message: vsFailureAlertDescription,
                                      preferredStyle: .alert)

        let okButton = UIAlertAction(title: vsFailureAlertButtonTitle,
                                         style: .default,
                                         handler: { _ in
                                            alert.dismiss(animated: true, completion: nil)
        })

        alert.addAction(okButton)

        UIApplication.shared.keyWindow?.rootViewController?.present(alert,
                                                          animated: true,
                                                          completion: nil)
    }
}
