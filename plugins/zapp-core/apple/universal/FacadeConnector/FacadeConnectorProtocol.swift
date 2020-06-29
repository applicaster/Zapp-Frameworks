//
//  FacadeConnectorProtocol.swift
//  ZappPlugins
//
//  Created by Anton Kononenko on 9/23/19.
//  Copyright © 2019 Applicaster LTD. All rights reserved.
//

import Foundation

@objc public protocol FacadeConnectorProtocol {
    var connectorInstance: FacadeConnector? { get }
}
