//
//  APPushProviderFirebase.swift
//  ZappPushPluginFirebase
//
//  Created by Anton Kononenko on 30/10/20.
//  Copyright © 2020 Applicaster Ltd.. All rights reserved.
//

import FirebaseCore
import FirebaseInstallations
import FirebaseMessaging
import XrayLogger
import ZappCore
import ZappPlugins
import ZappPushPluginsSDK

open class APPushProviderFirebase: ZPPushProvider {
    lazy var logger = Logger.getLogger(for: "\(kNativeSubsystemPath)/ZappPushPluginFirebase")

    var registeredTags: Set<String> = []
    override open func getKey() -> String {
        return model?.identifier ?? "ZappPushPluginFirebase"
    }

    override open func configureProvider() -> Bool {
        logger?.debugLog(message: "Handle Creation and configure plugin")
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        Messaging.messaging().delegate = self

        // Don't assign the UNUserNotificationCenter delegate because we are already handling the logic in the SDK
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in })

        UIApplication.shared.registerForRemoteNotifications()
        subscribeUUID()
        return true
    }

    override open func disable(completion: ((Bool) -> Void)?) {
        logger?.debugLog(message: "Handle disable plugin logic")
        removeTagsToDevice(Array(registeredTags)) { [weak self] _, _ in
            guard let `self` = self else { return }
            self.unsubscribeUUID()
            Messaging.messaging().delegate = nil
            UIApplication.shared.unregisterForRemoteNotifications()
            self.logger?.debugLog(message: "Plugin finished disabling")
            completion?(true)
        }
    }

    open func addTagsToDevice(_ tags: [String]?, completion: @escaping (_ success: Bool, _ tags: [String]?) -> Void) {
        guard let tags = tags else {
            completion(true, nil)
            return
        }

        logger?.debugLog(message: "Add tags to device",
                         data: ["tags": tags])

        var success = true
        let dispatchGroup = DispatchGroup()
        for tag in tags {
            dispatchGroup.enter()
            Messaging.messaging().subscribe(toTopic: tag) { [weak self] error in
                guard let `self` = self else { return }
                success = success && (error == nil)
                self.registeredTags.insert(tag)
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(success, tags)
        }
    }

    open func removeTagsToDevice(_ tags: [String]?, completion: @escaping (_ success: Bool, _ tags: [String]?) -> Void) {
        guard let tags = tags else {
            completion(true, nil)
            return
        }

        logger?.debugLog(message: "Remove tags to device",
                         data: ["tags": tags])

        var success = true
        let dispatchGroup = DispatchGroup()
        for tag in tags {
            dispatchGroup.enter()
            Messaging.messaging().unsubscribe(fromTopic: tag) { [weak self] error in
                guard let `self` = self else { return }
                self.registeredTags.remove(tag)
                success = success && (error == nil)
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(success, tags)
        }
    }

    func subscribeUUID() {
        logger?.debugLog(message: "Installations.installations().installationID")
        Installations.installations().installationID { [weak self] _, error in
            guard let `self` = self else { return }

            if let error = error {
                self.logger?.errorLog(message: "Installations.installations().installationID Error:\(error.localizedDescription)",
                                      data: ["error": error.localizedDescription])
            }
        }
    }

    func unsubscribeUUID() {
        logger?.debugLog(message: "Installations.installations().deleteID")
        Installations.installations().delete { [weak self] error in
            guard let `self` = self else { return }
            if let error = error {
                self.logger?.errorLog(message: "Installations.installations().deleteID Error:\(error.localizedDescription)",
                                      data: ["error": error.localizedDescription])
            }
        }
    }
}

extension APPushProviderFirebase: MessagingDelegate {
    open func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        guard !fcmToken.isEmpty else {
            return
        }

        logger?.debugLog(message: "messaging:didReceiveRegistrationToken: token:\(fcmToken)",
                         data: ["token": fcmToken])

        subscribeToTopics(with: messaging)
    }

    func subscribeToTopics(with messaging: Messaging) {
        let defaultTopic = "general"
        subscribe(messaging, toTopic: defaultTopic)

        if let additionalTopicsString = configurationJSON?["topics"] as? String {
            let additionalTopics = additionalTopicsString.components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { $0.isEmpty == false}
            for topic in additionalTopics {
                subscribe(messaging, toTopic: topic)
            }
        }
    }

    func subscribe(_ messaging: Messaging, toTopic topic: String) {
        messaging.subscribe(toTopic: topic) { error in
            if error == nil {
                self.logger?.debugLog(message: "Subscribed to topic: \(topic)")
            } else {
                self.logger?.debugLog(message: "Failed to subscribe to topic: \(topic)")
            }
        }
    }
}
