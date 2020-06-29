//
//  LocalNotificationManagerBase.swift
//  ZappLocalNotifications
//
//  Created by Anton Kononenko on 3/11/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation
import UserNotifications
import ZappCore

public class LocalNotificationManagerBase: NSObject, PluginAdapterProtocol, GeneralProviderProtocol {
    var disabled = false

    public required init(pluginModel: ZPPluginModel) {
        super.init()
        model = pluginModel
    }

    public var model: ZPPluginModel?

    public var providerName: String {
        return "Zapp Local Notifications"
    }

    public func prepareProvider(_ defaultParams: [String: Any],
                                completion: ((Bool) -> Void)?) {
        completion?(true)
    }

    public func disable(completion: ((Bool) -> Void)?) {
        disabled = true
        completion?(true)
    }

    let errorDomainNoIdentifier = "LOCAL_NOTIFICATION_MANAGER_NO_IDENTIFIER"
    let errorDomainNoTrigger = "LOCAL_NOTIFICATION_MANAGER_UNABLE_CREATE_TRIGGER"

    let notificationCenter = UNUserNotificationCenter.current()
    let options: UNAuthorizationOptions = [.alert,
                                           .sound,
                                           .badge]

    func requestScheduleLocalNotifications(competion: @escaping (_ isGranted: Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestPermission(competion: competion)
            case .authorized,
                 .provisional:
                competion(true)
            default:
                break
            }
        }
    }

    func requestPermission(competion: @escaping (_ isGranted: Bool) -> Void) {
        notificationCenter.requestAuthorization(options: options) { granted, error in
            competion(granted == true && error == nil)
        }
    }
}
