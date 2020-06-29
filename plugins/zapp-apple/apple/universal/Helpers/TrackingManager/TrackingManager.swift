//
//  TrackingManager.swift
//  ZappSDK
//
//  Created by Alex Zchut on 23/09/2019.
//

import UIKit

public class TrackingManager: NSObject {
    fileprivate let endPoint = "https://track.applicaster.com/events/v1/"

    public struct PlatformType {
        static let mobile = "mobile apple"
        static let tv = "tv apple"
    }

    public struct EventTypes {
        static let appPresented = "app_presented"
        static let willEnterForeground = "app_presented"
    }

    private struct EventParameters {
        static let eventName = "event_name"
        static let eventTime = "event_time"
        static let accountId = "account_id"
        static let versionId = "version_id"
        static let appFamily = "app_family"
        static let appName = "app_name"
        static let appVersion = "app_version"
        static let sdkVersion = "sdk_version"
        static let zappPlatform = "zapp_platform"
        static let deviceName = "device_name"
        static let deviceId = "device_uuid"
        static let os = "os"
        static let osVersion = "os_version"
        static let eventUuid = "event_uuid"
    }

    override init() {
        super.init()
        registerObservers()
    }

    public func track(for name: String,
                      completion: @escaping (_ succeed: Bool) -> Void) {
        var params = gatherBaseEventParameters()
        params[EventParameters.eventName] = name

        send(params,
             completion: completion)
    }

    private func gatherBaseEventParameters() -> [String: Any] {
        var params = [String: Any]()
        let sessionStorage = SessionStorage.sharedInstance

        if let accountsAccountId = sessionStorage.get(key: ZappStorageKeys.accountsAccountId,
                                                      namespace: nil) {
            params[EventParameters.accountId] = accountsAccountId
        }

        if let versionId = sessionStorage.get(key: ZappStorageKeys.versionId,
                                              namespace: nil) {
            params[EventParameters.versionId] = versionId
        }

        if let appFamilyId = sessionStorage.get(key: ZappStorageKeys.appFamilyId,
                                                namespace: nil) {
            params[EventParameters.appFamily] = appFamilyId
        }

        if let appName = sessionStorage.get(key: ZappStorageKeys.applicationName,
                                            namespace: nil) {
            params[EventParameters.appName] = appName
        }

        if let versionName = sessionStorage.get(key: ZappStorageKeys.versionName,
                                                namespace: nil) {
            params[EventParameters.appVersion] = versionName
        }

        if let sdkVersion = sessionStorage.get(key: ZappStorageKeys.sdkVersion,
                                               namespace: nil) {
            params[EventParameters.sdkVersion] = sdkVersion
        }

        if let platform = sessionStorage.get(key: ZappStorageKeys.platform,
                                             namespace: nil) {
            
            if platform == ZappStorageKeys.iOS {
                params[EventParameters.zappPlatform] = PlatformType.mobile
            } else if platform == ZappStorageKeys.tvOS {
                params[EventParameters.zappPlatform] = PlatformType.tv
            }
        }

        params[EventParameters.deviceName] = UIDevice.current.name
        params[EventParameters.os] = UIDevice.current.systemName
        params[EventParameters.osVersion] = UIDevice.current.systemVersion
        params[EventParameters.deviceId] = UUIDManager.deviceID
        params[EventParameters.eventUuid] = UUID().uuidString
        params[EventParameters.eventTime] = Int64((NSDate().timeIntervalSince1970 * 1000.0).rounded())

        return params
    }

    private func send(_ params: [String: Any],
                      completion: @escaping (_ succeed: Bool) -> Void) {
        let events = ["events": [params]]

        // vallidate url
        guard let url = URL(string: self.endPoint) else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json",
                         forHTTPHeaderField: "Content-Type")

        // vallidate params
        guard let jsonString = StorageHelper.getJSONStringFrom(dictionary: events),
            let jsonData = jsonString.data(using: .utf8) else {
            return
        }

        // assign json data
        request.httpBody = jsonData
        URLSession.shared.dataTask(with: request) { _, _, error in
            completion(error == nil)
        }.resume()
    }
}

// MARK: Observers

extension TrackingManager {
    func registerObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForeground(_:)),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }

    @objc func willEnterForeground(_ notification: Notification) {
        track(for: TrackingManager.EventTypes.willEnterForeground,
              completion: { _ in })
    }
}

// Example

// {
//    "events":[{
//    "account_id": "5aa0f616f0c743000828a70a",
//    "version_id": "dd96e586-6063-4deb-8eb9-2f6691e59150",
//    "app_family": 677,
//    "app_name": "zloof",
//    "app_version":"8.0.2",
//    "sdk_version":"8.0.0",
//    "zapp_platform":"mobile ios",
//    "device_name": "iphone 6s",
//    "os": "ios",
//    "os_version":"1.0.0",
//    "device_uuid": "5ca4a6b6540c4d0013743d54",
//    "event_uuid": "c61e14b4-3d04-4f98-9455-c9e058a41d36",
//    "event_name": "app_launched",
//    "event_time": {{$timestamp}}000"
//    }]}
