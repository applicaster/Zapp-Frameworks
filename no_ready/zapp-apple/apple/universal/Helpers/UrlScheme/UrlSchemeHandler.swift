//
//  UrlSchemeHandler.swift
//  ZappApple
//
//  Created by Alex Zchut on 26/02/2020.
//

import Foundation

public class UrlSchemeHandler {
    
    enum SystemActions: String {
        case generateNewUUID
    }
    
    public class func handle(with rootViewController: RootController?,
                             application: UIApplication,
                             open url: URL,
                             options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        
        var retValue = false
        //create action with string
        let action = SystemActions(rawValue: url.host ?? "")
        
        //check if action defined anc call its implementation or skip
        switch action {
        case .generateNewUUID:
            retValue = self.handleUUIDregeneration(with: rootViewController)
        default:
            break
        }
        
       return retValue
    }
}
