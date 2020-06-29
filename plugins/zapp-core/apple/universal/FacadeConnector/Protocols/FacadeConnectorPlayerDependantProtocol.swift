//
//  FacadeConnectorPlayerDependantProtocol.swift
//  ZappPlugins
//
//  Created by Anton Kononenko on 9/23/19.
//  Copyright © 2019 Applicaster LTD. All rights reserved.
//

import Foundation

// Allows lower layer classes like plugins to send analytics using the analytics providers set for the app
@objc public protocol FacadeConnectorPlayerDependantProtocol: PlayerObserverProtocol {
}
