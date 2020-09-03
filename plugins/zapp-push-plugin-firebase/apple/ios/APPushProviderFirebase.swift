//
//  APPushProviderFirebase.swift
//  Pods
//
//  Created by Egor Brel on 2/22/19.
//

import ZappPlugins
import ZappPushPluginsSDK
import UserNotifications
import FirebaseMessaging
import FirebaseCore

open class APPushProviderFirebase: ZPPushProvider {

    override open func getKey() -> String {
        return "firebase"
    }

    override open func configureProvider() -> Bool {
        if (FirebaseApp.app() == nil) {
            FirebaseApp.configure()
        }
        Messaging.messaging().delegate = self
        
        //Don't assign the UNUserNotificationCenter delegate because we are already handling the logic in the SDK
        if #available(iOS 10.0, *) {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound],
                                                                                  categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        UIApplication.shared.registerForRemoteNotifications()
        
        return true
    }
    
    open func addTagsToDevice(_ tags: [String]?, completion: @escaping (_ success: Bool ,_ tags: [String]?) -> Void) {
        guard let tags = tags else {
            completion(true, nil)
            return
        }
        
        var success = true
        let dispatchGroup = DispatchGroup()
        for tag in tags {
            dispatchGroup.enter()
            Messaging.messaging().subscribe(toTopic: tag) { (error) in
                success = success && (error == nil)
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
            Messaging.messaging().unsubscribe(fromTopic: tag) { (error) in
                success = success && (error == nil)
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(success, tags)
        }
    }
}

extension APPushProviderFirebase : MessagingDelegate {
    
    open func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        NSLog("Firebase registration token %@", fcmToken) //NSLog instead of print so it can be visualized without XCode
    }
}
