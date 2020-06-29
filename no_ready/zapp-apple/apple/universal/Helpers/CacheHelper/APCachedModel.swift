//
//  APCachedModel.swift
//  ZappPlugins
//
//  Created by Alex Zchut on 13/02/2019.
//

import UIKit

@objc public class APCachedModel: NSObject {
    var object: JsonSerializableProtocol
    var identifier: String
    var filename: String {
        return (className+identifier).toMd5hash()+".dat"
    }
    var className: String {
        return NSStringFromClass(type(of: object))
    }

    public init(object: JsonSerializableProtocol, identifier: String = "") {
        self.object = object
        self.identifier = identifier
    }

    /*
     * Returns the local url path of the file
     */
    public func localURLPath() -> URL? {
        var retVal: URL?

        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        //https://developer.apple.com/library/archive/documentation/General/Conceptual/AppleTV_PG/index.html#//apple_ref/doc/uid/TP40015241
        // tvOS can not have local storage
        #if os(tvOS)
        path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        #endif
        if let documentDirectoryPath:String = path.first {
            let dirPath = documentDirectoryPath.appendingFormat("/Objects")
            if !FileManager.default.fileExists(atPath: dirPath) {
                do {
                    try FileManager.default.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
                } catch _ {}
            }
            retVal = URL(fileURLWithPath: dirPath.appendingFormat("/\(filename)"))
        }
        return retVal
    }

    /*
     * Check if the File exists in localstorage
     */
    public func isInLocalStorage() -> Bool {
        guard let localURL = localURLPath() else {
            return false
        }
        return FileManager.default.fileExists(atPath: localURL.path)
    }

    /*
     * Save a temp URL in local memory of an app
     */
    public func saveObjectToStorage() -> Bool {
        var success = false
        let fileManager = FileManager.default
        if let localURLPath = localURLPath() {
            do {
                if isInLocalStorage() {
                    try fileManager.removeItem(at: localURLPath)
                }

                if let data = object.jsonData() {
                    try data.write(to: localURLPath,
                                   options: .atomic)
                    success = true
                }
            } catch let error {
                debugPrint("An error occurred while writing file file to destination url, caught: \(error)")
            }
        }
        return success
    }

    public func loadObjectFromStorage() -> Bool {
        var success = false
        guard let localURL = localURLPath(),
            let data = FileManager.default.contents(atPath: localURL.path) else {
            return success
        }
        do {
            if let dict = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers]) as? Dictionary<String, AnyObject>,
                let classType = NSClassFromString(className) as? JsonSerializableProtocol.Type {
                self.object = classType.init(dictionary: dict)
                success = true
            }
        } catch let error {
            debugPrint("An error occurred while reading file, caught: \(error)")
        }
        return success
    }

    override public var description: String {
        return "JsonObject -> filename: \(filename) className: \(className), identifier: \(self.identifier)"
    }

    public func deleteLocalStorage() {
        guard let localURL = localURLPath() else {
            return
        }

        do {
            try FileManager.default.removeItem(atPath: localURL.path)
        }
        catch {}
    }
}
