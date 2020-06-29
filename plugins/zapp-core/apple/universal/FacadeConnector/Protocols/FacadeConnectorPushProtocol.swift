//
//  FacadeConnectorPushProtocol.swift
//  ZappCore
//
//  Created by Anton Kononenko on 1/27/20.
//

import Foundation

import Foundation

@objc public protocol FacadeConnectorPushProtocol {
    @objc func addTagsToDevice(_ tags: [String]?,
                               completion: @escaping (_ success: Bool, _ tags: [String]?) -> Void)

    @objc func removeTagsToDevice(_ tags: [String]?,
                                  completion: @escaping (_ success: Bool, _ tags: [String]?) -> Void)

    @objc func getDeviceTags() -> [String:[String]]
}
