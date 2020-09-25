//
//  ReachabilityManagerDelegate.swift
//  ZappApple
//
//  Created by Anton Kononenko on 6/10/19.
//  Copyright © 2019 Applicaster LTD. All rights reserved.
//

import Foundation
import Reachability

protocol ReachabilityManagerDelegate {
    func reachabilityChanged(connection: Reachability.Connection)
}
