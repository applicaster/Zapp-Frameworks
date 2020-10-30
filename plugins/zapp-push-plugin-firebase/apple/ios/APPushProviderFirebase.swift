//
//  APPushProviderFirebase.swift
//  Pods
//
//  Created by Egor Brel on 2/22/19.
//

import FirebaseCore
import FirebaseInstanceID
import FirebaseMessaging
import ZappPlugins
import ZappPushPluginsSDK

open class APPushProviderFirebase: ZPPushProvider {
    var registeredTags: Set<String> = []
    override open func getKey() -> String {
        return model?.identifier ?? "ZappPushPluginFirebase"
    }

    override open func configureProvider() -> Bool {
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
        removeTagsToDevice(Array(registeredTags)) { [weak self] _, _ in
            guard let `self` = self else { return }
            self.unsubscribeUUID()
            Messaging.messaging().delegate = nil
            UIApplication.shared.unregisterForRemoteNotifications()
            completion?(true)
        }
    }

    open func addTagsToDevice(_ tags: [String]?, completion: @escaping (_ success: Bool, _ tags: [String]?) -> Void) {
        guard let tags = tags else {
            completion(true, nil)
            return
        }
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
        InstanceID.instanceID().instanceID { _, error in
            if let error = error {
                print("Error fetching instance ID: \(error.localizedDescription)")
            }
        }
    }

    func unsubscribeUUID() {
        InstanceID.instanceID().deleteID { error in
            if let error = error {
                print("Error deleting instance ID: \(error.localizedDescription)")
            }
        }
    }
}

extension APPushProviderFirebase: MessagingDelegate {
    open func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        NSLog("Firebase registration token %@", fcmToken) // NSLog instead of print so it can be visualized without XCode
    }
}
