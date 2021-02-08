//
//  UUIDManager.swift
//  ZappApple
//
//  Created by Anton Kononenko on 2/4/20.
//

import Foundation
import ZappCore

let UUIDKey = "APUUID"

public class UUIDManager {
    /// The unique identifier for this user.
    /// The unique identifier if one has been generated. <code>nil</code> otherwise.
    public static var deviceID: String {
        return fetchExistingKey()?.value ?? registerNewUUID()
    }

    static func fetchExistingKey() -> (key: String, value: String)? {
        var retValue: (key: String, value: String)?
        guard let bundleIdentifier = SessionStorage.sharedInstance.get(key: ZappStorageKeys.bundleIdentifier, namespace: nil),
              let deviceType = SessionStorage.sharedInstance.get(key: ZappStorageKeys.deviceType, namespace: nil) else {
            return retValue
        }

        let uuidType1 = "\(bundleIdentifier) - APUUID"
        let uuidType2 = "\(bundleIdentifier)-\(deviceType)-APUUID"

        if let value = Keychain.getStringForKey(uuidType1) {
            retValue = (uuidType1, value)
        } else if let value = Keychain.getStringForKey(uuidType2) {
            retValue = (uuidType2, value)
        } else if let value = Keychain.getStringForKey(UUIDKey) {
            retValue = (UUIDKey, value)
        }
        return retValue
    }

    public class func regenerateUUID() {
        // delete existing key
        if let existingKeyData = fetchExistingKey() {
            Keychain.deleteString(forKey: existingKeyData.key)
        }
        // create new key
        _ = registerNewUUID()
    }

    /// Creates new UUID key and save it to Keychain
    class func registerNewUUID() -> String {
        let retVal = UUID().uuidString

        Keychain.setString(retVal,
                           forKey: UUIDKey)
        return retVal
    }
}
