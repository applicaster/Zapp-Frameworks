//
//  JsonSerializableProtocol.swift
//  ZappPlugins
//
//  Created by Alex Zchut on 13/02/2019.
//

import UIKit

@objc public protocol JsonSerializableProtocol: NSObjectProtocol {
    var dictForJsonSerialization: [String: Any] { get }
    init()
    init(dictionary: [String: Any])
}

extension JsonSerializableProtocol {
    /// Converts a JSONSerializable conforming class to a JSON object.
    func jsonData() -> Data? {
        var retValue:Data?
        do {
            retValue = try JSONSerialization.data(withJSONObject: self.dictForJsonSerialization, options: [.prettyPrinted])
        }
        catch {

        }
        return retValue
    }
}
