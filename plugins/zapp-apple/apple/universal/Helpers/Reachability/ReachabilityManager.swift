//
//  ReachabilityManager.swift
//  ZappApple
//
//  Created by Anton Kononenko on 6/10/19.
//  Copyright © 2019 Applicaster LTD. All rights reserved.
//

import Foundation
import Network

class ReachabilityManager {
    let monitor: NWPathMonitor?
    var delegate: ReachabilityManagerDelegate

    init(delegate: ReachabilityManagerDelegate) {
        self.delegate = delegate
        self.monitor = NWPathMonitor()
        startObserve()
    }

    func startObserve() {
        monitor?.pathUpdateHandler = { path in
            if path.status == .satisfied {
                let interfaceTypes = path.availableInterfaces.map(\.type)
                self.delegate.reachabilityChanged(.connected(interfaceTypes))
            } else {
                self.delegate.reachabilityChanged(.disconnected)
            }
        }
        
        let queue = DispatchQueue(label: "ReachabilityMonitor")
        monitor?.start(queue: queue)
    }
}
