//
//  FacadeConnectorPushProtocol.swift
//  ZappCore
//
//  Created by Anton Kononenko on 1/27/20.
//

import Foundation

import Foundation

public protocol FacadeConnectorPushProtocol {
    func addTagsToDevice(_ tags: [String]?,
                               completion: @escaping (Result<[String]?, Error>) -> Void)

    func removeTagsToDevice(_ tags: [String]?,
                                  completion: @escaping (Result<[String]?, Error>) -> Void)

    func getDeviceTags() -> [String:[String]]
}
