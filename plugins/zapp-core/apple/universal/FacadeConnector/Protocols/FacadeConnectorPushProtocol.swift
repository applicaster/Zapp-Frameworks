//
//  FacadeConnectorPushProtocol.swift
//  ZappCore
//
//  Created by Anton Kononenko on 1/27/20.
//

import Foundation

import Foundation

public protocol FacadeConnectorPushProtocol {
    func addTags(_ tags: [String]?,
                               completion: @escaping (Result<[String]?, Error>) -> Void)

    func removeTags(_ tags: [String]?,
                                  completion: @escaping (Result<[String]?, Error>) -> Void)
    
    @available(*, deprecated, message: "Deprecated since QB SDK 5.1.0, use addTags(_, completion:) instead")
    func addTagsToDevice(_ tags: [String]?,
                               completion: @escaping (_ success: Bool, _ tags: [String]?) -> Void)

    @available(*, deprecated, message: "Deprecated since QB SDK 5.1.0, use removeTags(_, completion:) instead")
    func removeTagsToDevice(_ tags: [String]?,
                                  completion: @escaping (_ success: Bool, _ tags: [String]?) -> Void)

    func getDeviceTags() -> [String:[String]]
}
