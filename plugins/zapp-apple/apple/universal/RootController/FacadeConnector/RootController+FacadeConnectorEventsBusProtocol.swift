//
//  RootController+FacadeConnectorEventsBusProtocol.swift
//  ZappApple
//
//  Created by Alex Zchut on 14/02/2021.
//  Copyright © 2021 Applicaster LTD. All rights reserved.
//

import Foundation
import ZappCore

extension RootController: FacadeConnectorEventsBusProtocol {
    public func post(_ name: String, sender: Any? = nil) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: name), object: sender)
    }

    public func post(_ name: String, sender: Any? = nil, userInfo: [AnyHashable: Any]?) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: name), object: sender, userInfo: userInfo)
    }

    @discardableResult public func subscribe(_ target: AnyObject, name: String, handler: @escaping ((Notification?) -> Void)) -> NSObjectProtocol {
        subscribe(target, name: name, sender: nil, handler: handler)
    }

    @discardableResult public func subscribe(_ target: AnyObject, name: String, sender: Any?, handler: @escaping ((Notification?) -> Void)) -> NSObjectProtocol {
        eventsBus.subscribe(target, name: name, sender: sender, handler: handler)
    }

    public func unsubscribe(_ target: AnyObject) {
        eventsBus.unsubscribe(target)
    }

    public func unsubscribe(_ target: AnyObject, name: String) {
        eventsBus.unsubscribe(target, name: name)
    }
}
