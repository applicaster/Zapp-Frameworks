//
//  EventsBus.swift
//  ZappApple
//
//  Created by Alex Zchut on 14/02/2021.
//  Copyright © 2021 Applicaster LTD. All rights reserved.

//  Based on example from https://github.com/cesarferreira/SwiftEventBus

import Foundation
import XrayLogger
import ZappCore

struct NamedObserver {
    let observer: NSObjectProtocol
    let name: String
}

public class EventsBus {
    let logger = Logger.getLogger(for: EventsBusManagerLogs.subsystem)
    
    lazy var queue: DispatchQueue = {
        let uuid = NSUUID().uuidString
        let queueLabel = "events-bus-\(uuid)"
        return DispatchQueue(label: queueLabel)
    }()

    lazy var cache = [UInt: [NamedObserver]]()

    @discardableResult
    public func subscribe(_ target: AnyObject,
                          name: String,
                          sender: Any?,
                          handler: @escaping ((Notification?) -> Void)) -> NSObjectProtocol {
        let id = UInt(bitPattern: ObjectIdentifier(target))
        let observer = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: name),
                                                              object: sender,
                                                              queue: OperationQueue.main,
                                                              using: handler)
        let namedObserver = NamedObserver(observer: observer, name: name)

        queue.sync {
            if let namedObservers = cache[id] {
                cache[id] = namedObservers + [namedObserver]
            } else {
                cache[id] = [namedObserver]
            }
        }
        
        logger?.debugLog(template: EventsBusManagerLogs.subscribed,
                         data: ["name" : name])

        return observer
    }
    
    public func unsubscribe(_ target: AnyObject) {
        let id = UInt(bitPattern: ObjectIdentifier(target))
        let center = NotificationCenter.default

        queue.sync {
            if let namedObservers = cache.removeValue(forKey: id) {
                for namedObserver in namedObservers {
                    center.removeObserver(namedObserver.observer)
                }
            }
        }
        logger?.debugLog(template: EventsBusManagerLogs.unsubscribedFromAll,
                         data: ["target": String(describing: type(of: target))])
    }

    public func unsubscribe(_ target: AnyObject, name: String) {
        let id = UInt(bitPattern: ObjectIdentifier(target))
        let center = NotificationCenter.default

        queue.sync {
            if let namedObservers = cache[id] {
                cache[id] = namedObservers.filter({ (namedObserver: NamedObserver) -> Bool in
                    if namedObserver.name == name {
                        center.removeObserver(namedObserver.observer)
                        return false
                    } else {
                        return true
                    }
                })
            }
        }
        logger?.debugLog(template: EventsBusManagerLogs.unsubscribed,
                         data: ["name" : name,
                                "target": String(describing: type(of: target))])

    }
}
