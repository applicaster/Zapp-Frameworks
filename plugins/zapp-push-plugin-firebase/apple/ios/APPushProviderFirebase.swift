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
    let localStorageTopicsParam = "topics"

    var registeredTopics: Set<String> = []
    override open func getKey() -> String {
        return model?.identifier ?? "ZappPushPluginFirebase"
    }

    override open func configureProvider() -> Bool {
        logger?.debugLog(message: "Handle Creation and configure plugin")
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        Messaging.messaging().delegate = self
        setDefaultTopicIfNeeded()
        savePluginConfigurationForExtensionsUsage()

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
        removeTagsToDevice(Array(registeredTopics)) { [weak self] _, _ in
            guard let `self` = self else { return }
            self.unsubscribeUUID()
            Messaging.messaging().delegate = nil
            UIApplication.shared.unregisterForRemoteNotifications()
            self.logger?.debugLog(message: "Plugin finished disabling")
            completion?(true)
        }
    }

    open func addTagsToDevice(_ tags: [String]?,
                              completion: @escaping (_ success: Bool, _ tags: [String]?) -> Void) {
        guard let topics = tags else {
            completion(true, nil)
            return
        }

        logger?.debugLog(message: "Subscribe to topics",
                         data: ["topics": topics])

        let dispatchGroup = DispatchGroup()
        for topic in topics {
            dispatchGroup.enter()
            Messaging.messaging().subscribe(toTopic: topic) { error in
                if error == nil {
                    self.registeredTopics.insert(topic)
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.logger?.debugLog(message: "Currently subscribed topics updated",
                                  data: ["topics": Array(self.registeredTopics)])

            self.updateTopicsInLocalStorage()
            completion(true, topics)
        }
    }

    open func removeTagsToDevice(_ tags: [String]?,
                                 completion: @escaping (_ success: Bool, _ tags: [String]?) -> Void) {
        guard let topics = tags else {
            completion(true, nil)
            return
        }

        logger?.debugLog(message: "Unsubscribe from topics",
                         data: ["topics": topics])

        let dispatchGroup = DispatchGroup()
        for topic in topics {
            dispatchGroup.enter()
            Messaging.messaging().unsubscribe(fromTopic: topic) { error in
                if error == nil {
                    self.registeredTopics.remove(topic)
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.logger?.debugLog(message: "Currently subscribed topics updated",
                                  data: ["topics": Array(self.registeredTopics)])

            self.updateTopicsInLocalStorage()
            completion(true, topics)
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

    fileprivate func setDefaultTopicIfNeeded() {
        if let _ = registeredTopicsInLocalStorage {
            // topics already defined, no changes needed
        } else {
            // add default value
            if let defaultTopic = configurationJSON?["default_topic"] as? String,
               defaultTopic.isEmpty == false {
                addTagsToDevice([defaultTopic]) { _, _ in
                    // do nothing
                }
            }
        }
    }

    fileprivate var namespace: String? {
        return model?.identifier
    }

    fileprivate var registeredTopicsInLocalStorage: [String]? {
        let topicsString = FacadeConnector.connector?.storage?.localStorageValue(for: localStorageTopicsParam,
                                                                                 namespace: namespace)

        return topicsString?.components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
    }

    fileprivate func updateTopicsInLocalStorage() {
        let topics = Array(registeredTopics).joined(separator: ",")
        _ = FacadeConnector.connector?.storage?.localStorageSetValue(for: localStorageTopicsParam,
                                                                     value: topics,
                                                                     namespace: namespace)
    }

    fileprivate func savePluginConfigurationForExtensionsUsage() {
        guard let configurationJSON = configurationJSON,
              let appGroups = Bundle.main.object(forInfoDictionaryKey: "SupportedAppGroups") as? [String],
              appGroups.count > 0,
              let userDefaults = UserDefaults(suiteName: appGroups.first) else {
            return
        }
        userDefaults.setValue(configurationJSON, forKey: "configurationJSON")
    }
}

extension APPushProviderFirebase: MessagingDelegate {
    open func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        guard !fcmToken.isEmpty else {
            logger?.debugLog(message: "didReceiveRegistrationToken: token is empty")
            return
        }

        logger?.debugLog(message: "didReceiveRegistrationToken: token:\(fcmToken)",
                         data: ["token": fcmToken])

        // clean local registered topics
        registeredTopics.removeAll()
        // subscribe to topics appears in local storage
        addTagsToDevice(registeredTopicsInLocalStorage, completion: { _, _ in
            // do nothing
        })
    }
}
