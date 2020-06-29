//
//  String+Extension.swift
//  ZappCore
//
//  Created by Alex Zchut on 26/04/2020.
//

import Foundation

extension String {
    public func replaceUrlHost(to newHost: String?) -> String {
        guard let newHost = newHost, newHost.isEmpty == false,
            let url = URL(string: self),
            let host = url.host else {
            return self
        }
        
        return self.replacingOccurrences(of: host, with: newHost)
    }
}
