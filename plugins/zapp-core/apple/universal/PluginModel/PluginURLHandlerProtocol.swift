//
//  PluginURLHandlerProtocol.swift
//  ZappCore
//
//  Created by Anton Kononenko on 7/29/20.
//

import Foundation

// Currently not in use, remove future if not neede
@objc public protocol PluginURLHandlerProtocol: NSObjectProtocol {

    @objc optional func handlePluginURLScheme(with rootViewController: UIViewController?,
                                              url: URL) -> Bool
    
    @objc optional func canHandlePluginURLScheme(with url: URL) -> Bool
}
