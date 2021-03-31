//
//  LoggerAssistanceManager.swift
//  ZappApple
//
//  Created by Alex Zchut on 26/10/2020.
//

import Foundation
import XrayLogger

public class LoggerAssistanceManager {
    let logger = Logger.getLogger(for: LoggerAssistanceManagerLogs.subsystem)

    public func presentAuthenticationForRemoteEventsLogging(with params: [String: Any],
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
                                                   SettingsBundleHelper.setSettingsBundleLastUsedBoolValue(forKey: .loggerAssistanceRemoteEventsLogging,
                                                                                                           value: true)

                                                   self.logger?.debugLog(template: LoggerAssistanceManagerLogs.remoteLoggingPassedAuthentication,
                                                                         data: ["value": "\(intValue)"])
                                               }
                                           })

        let cancelButton = UIAlertAction(title: cancelTitle,
                                         style: .cancel,
                                         handler: { _ in
                                             alert.dismiss(animated: true, completion: {
                                                 self.logger?.debugLog(template: LoggerAssistanceManagerLogs.remoteLoggingCancelled)
                                                 self.resetToDefaultRemoteLoggingState()
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

        logger?.debugLog(template: LoggerAssistanceManagerLogs.remoteLoggingPresentAuthentication)
    }

    fileprivate func resetToDefaultRemoteLoggingState() {
        SettingsBundleHelper.setSettingsBundleBoolValue(forKey: .loggerAssistanceRemoteEventsLogging,
                                                        value: false)
        SettingsBundleHelper.setSettingsBundleLastUsedBoolValue(forKey: .loggerAssistanceRemoteEventsLogging,
                                                                value: false)

        logger?.debugLog(template: LoggerAssistanceManagerLogs.remoteLoggingResetToDefaultState)
    }
}
