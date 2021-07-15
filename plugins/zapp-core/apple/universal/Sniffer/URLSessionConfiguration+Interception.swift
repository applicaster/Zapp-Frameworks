//
//  URLSessionConfiguration+Interception.swift
//  ZappApple
//
//  Created by Alex Zchut on 24/02/2021.
//

import Foundation

extension URLSessionConfiguration {
    @objc
    static func setupSwizzledSessionConfiguration() {
        guard self == URLSessionConfiguration.self else {
            return
        }

        let defaultSessionConfiguration = class_getClassMethod(URLSessionConfiguration.self, #selector(getter: URLSessionConfiguration.default))
        let swizzledDefaultSessionConfiguration = class_getClassMethod(URLSessionConfiguration.self, #selector(URLSessionConfiguration.swizzledDefaultSessionConfiguration))
        method_exchangeImplementations(defaultSessionConfiguration!, swizzledDefaultSessionConfiguration!)

        let ephemeralSessionConfiguration = class_getClassMethod(URLSessionConfiguration.self, #selector(getter: URLSessionConfiguration.ephemeral))
        let swizzledEphemeralSessionConfiguration = class_getClassMethod(URLSessionConfiguration.self, #selector(URLSessionConfiguration.swizzledEphemeralSessionConfiguration))
        method_exchangeImplementations(ephemeralSessionConfiguration!, swizzledEphemeralSessionConfiguration!)
    }

    @objc class func swizzledDefaultSessionConfiguration() -> URLSessionConfiguration {
        let configuration = swizzledDefaultSessionConfiguration()
        URLProtocol.registerClass(Sniffer.self)
        configuration.protocolClasses?.insert(Sniffer.self, at: 0)
        return configuration
    }

    @objc class func swizzledEphemeralSessionConfiguration() -> URLSessionConfiguration {
        let configuration = swizzledEphemeralSessionConfiguration()
        URLProtocol.registerClass(Sniffer.self)
        configuration.protocolClasses?.insert(Sniffer.self, at: 0)
        return configuration
    }
}
