//
//  FacadeConnectorEventsBusProtocol.swift
//  ZappCore
//
//  Created by Alex Zchut on 14/02/2021.
//  Copyright © 2021 Applicaster LTD. All rights reserved.
//

import Foundation

@objc public protocol FacadeConnectorEventsBusProtocol {
    @objc func post(_ name: String, sender: Any?)
    @objc func post(_ name: String, sender: Any?, userInfo: [AnyHashable: Any]?)
    @objc func post(_ name: String, userInfo: [AnyHashable: Any]?)

    @discardableResult @objc func subscribe(_ target: AnyObject, name: String, sender: Any?, handler: @escaping ((Notification?) -> Void)) -> NSObjectProtocol
    @discardableResult @objc func subscribe(_ target: AnyObject, name: String, handler: @escaping ((Notification?) -> Void)) -> NSObjectProtocol

    @objc func unsubscribe(_ target: AnyObject)
    @objc func unsubscribe(_ target: AnyObject, name: String)
}
