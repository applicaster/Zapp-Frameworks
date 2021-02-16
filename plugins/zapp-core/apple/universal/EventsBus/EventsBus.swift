//
//  EventsBus.swift
//  ZappApple
//
//  Created by Alex Zchut on 14/02/2021.
//  Copyright © 2021 Applicaster LTD. All rights reserved.

//  Based on example from https://github.com/cesarferreira/SwiftEventBus

import Foundation
import XrayLogger

struct NamedObserver {
    let observer: NSObjectProtocol
    let name: String
}

public class EventsBus {
    static let shared = EventsBus()
    let logger = Logger.getLogger(for: EventsBusLogs.subsystem)

    lazy var queue: DispatchQueue = {
        let uuid = NSUUID().uuidString
        let queueLabel = "events-bus-\(uuid)"
        return DispatchQueue(label: queueLabel)
    }()

    lazy var cache = [UInt: [NamedObserver]]()

    public static func post(_ name: String, sender: Any? = nil, userInfo: [AnyHashable: Any]? = nil) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: name), object: sender, userInfo: userInfo)
    }

    @discardableResult
    public static func subscribe(_ target: AnyObject,
                                 name: String,
                                 sender: Any? = nil,
                                 handler: @escaping ((Notification?) -> Void)) -> NSObjectProtocol {
        let id = UInt(bitPattern: ObjectIdentifier(target))
        let observer = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: name),
                                                              object: sender,
                                                              queue: OperationQueue.main,
                                                              using: handler)
        let namedObserver = NamedObserver(observer: observer, name: name)

        shared.queue.sync {
            if let namedObservers = shared.cache[id] {
                shared.cache[id] = namedObservers + [namedObserver]
            } else {
                shared.cache[id] = [namedObserver]
            }
        }

        shared.logger?.debugLog(message: EventsBusLogs.subscribed.message,
                                category: EventsBusLogs.subscribed.category,
                                data: ["name": name])

        return observer
    }

    public static func unsubscribe(_ target: AnyObject) {
        let id = UInt(bitPattern: ObjectIdentifier(target))
        let center = NotificationCenter.default

        shared.queue.sync {
            if let namedObservers = shared.cache.removeValue(forKey: id) {
                for namedObserver in namedObservers {
                    center.removeObserver(namedObserver.observer)
                }
            }
        }

        shared.logger?.debugLog(message: EventsBusLogs.unsubscribedFromAll.message,
                                category: EventsBusLogs.unsubscribedFromAll.category,
                                data: ["target": String(describing: type(of: target))])
    }

    public static func unsubscribe(_ target: AnyObject, name: String) {
        let id = UInt(bitPattern: ObjectIdentifier(target))
        let center = NotificationCenter.default

        shared.queue.sync {
            if let namedObservers = shared.cache[id] {
                shared.cache[id] = namedObservers.filter({ (namedObserver: NamedObserver) -> Bool in
                    if namedObserver.name == name {
                        center.removeObserver(namedObserver.observer)
                        return false
                    } else {
                        return true
                    }
                })
            }
        }

        shared.logger?.debugLog(message: EventsBusLogs.unsubscribed.message,
                                category: EventsBusLogs.unsubscribed.category,
                                data: ["name": name,
                                       "target": String(describing: type(of: target))])
    }
}
