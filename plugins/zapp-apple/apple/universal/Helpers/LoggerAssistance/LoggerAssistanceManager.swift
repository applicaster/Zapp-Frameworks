//
//  LoggerAssistanceManager.swift
//  ZappApple
//
//  Created by Alex Zchut on 26/10/2020.
//

import Foundation

public class LoggerAssistanceManager {
    public func presentAuthentication(with params: [String: Any],
                                      on rootController: RootController?) {
        guard let rootController = rootController else {
            return
        }

        let title = "App Assistance"
        let description = "Please enter the code to turn on app assistance"
        let continueTitle = "Continue"
        let cancelTitle = "Cancel"

        let alert = UIAlertController(title: title,
                                      message: description,
                                      preferredStyle: .alert)

        let continueButton = UIAlertAction(title: continueTitle,
                                           style: .destructive,
                                           handler: { _ in
                                               if let codeTextField = alert.textFields?.first,
                                                   let value = codeTextField.text,
                                                   let intValue = Int(value) {
                                                
                                                   SettingsBundleHelper.setSettingsBundleLastUsedBoolValue(forKey: .loggerAssistance,
                                                                                                           value: true)

                                                   print("entered value is: \(intValue)")
                                               }
                                           })

        let cancelButton = UIAlertAction(title: cancelTitle,
                                         style: .cancel,
                                         handler: { _ in
                                             alert.dismiss(animated: true, completion: {
                                                 // set to default
                                                 SettingsBundleHelper.setSettingsBundleBoolValue(forKey: .loggerAssistance,
                                                                                                 value: false)
                                                 SettingsBundleHelper.setSettingsBundleLastUsedBoolValue(forKey: .loggerAssistance,
                                                                                                         value: false)
                                             })
                                         })

        alert.addTextField { textField in
            textField.placeholder = ""
            textField.keyboardType = .numberPad
        }
        alert.addAction(continueButton)
        alert.addAction(cancelButton)

        rootController.userInterfaceLayerViewController?.present(alert,
                                                                 animated: true,
                                                                 completion: nil)
    }
}
