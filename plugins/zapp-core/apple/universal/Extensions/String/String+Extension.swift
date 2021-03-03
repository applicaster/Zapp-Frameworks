//
//  String+Extension.swift
//  ZappCore
//
//  Created by Alex Zchut on 26/04/2020.
//

import CommonCrypto
import Foundation

extension String {
    public func replaceUrlHost(to newHost: String?) -> String {
        guard let newHost = newHost, newHost.isEmpty == false,
              let url = URL(string: self),
              let host = url.host else {
            return self
        }

        return replacingOccurrences(of: host, with: newHost)
    }
}

enum Regex {
    static let ipAddress = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$"
    static let hostname = "^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9])$"
    static let ipAdressV4WithPort = "(\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}):(\\d{1,5})"
}

extension String {
    public var isIPv4: Bool {
        var sin = sockaddr_in()
        return withCString({ cstring in inet_pton(AF_INET, cstring, &sin.sin_addr) }) == 1
    }

    public var isIPv6: Bool {
        var sin6 = sockaddr_in6()
        return withCString({ cstring in inet_pton(AF_INET6, cstring, &sin6.sin6_addr) }) == 1
    }

    public var isIPv4WithPort: Bool {
        return matches(pattern: Regex.ipAdressV4WithPort)
    }

    public var isIpAddress: Bool { return isIPv6 || isIPv4 }

    private func matches(pattern: String) -> Bool {
        return range(of: pattern,
                     options: .regularExpression,
                     range: nil,
                     locale: nil) != nil
    }

    public func md5() -> String {
        let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
        var digest = Array<UInt8>(repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5_Init(context)
        CC_MD5_Update(context, self, CC_LONG(lengthOfBytes(using: String.Encoding.utf8)))
        CC_MD5_Final(&digest, context)
        context.deallocate()
        var hexString = ""
        for byte in digest {
            hexString += String(format: "%02x", byte)
        }

        return hexString
    }
}
