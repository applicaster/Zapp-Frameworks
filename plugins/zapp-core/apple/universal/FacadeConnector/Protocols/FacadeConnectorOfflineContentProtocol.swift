//
//  FacadeConnectorOfflineContentProtocol.swift
//  ZappCore
//
//  Created by Alex Zchut on 16/12/2020.
//  Copyright © 2020 Applicaster LTD. All rights reserved.
//

import Foundation

@objc public protocol FacadeConnectorOfflineContentProtocol {
    @objc func localUrl(for identifier: String?) -> String?

}
