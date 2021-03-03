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
    public struct Event {
        public let version: String = "1.0"
        public let id: UUID = UUID()
        public let time: Date = Date()
        public let type: String
        public let source: String?
        public let subject: String?
        public let data: [AnyHashable: Any]?

        var content: [AnyHashable: Any] {
            return ["event": self]
        }

        lazy var timeString: String = {
            var dateFormatter = DateFormatter()
            let format = "yyyy-MM-dd'T'HH:mm:ssZ"
            dateFormatter.dateFormat = format
            return dateFormatter.string(from: time)
        }()

        public init(topic: EventsBusTopic,
                    source: String? = nil,
                    subject: String? = nil,
                    data: [AnyHashable: Any]) {
            type = topic.description
            self.source = source
            self.subject = subject
            self.data = data
        }
    }

    static let shared = EventsBus()
    let logger = Logger.getLogger(for: EventsBusLogs.subsystem)

    lazy var queue: DispatchQueue = {
        let uuid = NSUUID().uuidString
        let queueLabel = "events-bus-\(uuid)"
        return DispatchQueue(label: queueLabel)
    }()

    lazy var cache = [UInt: [NamedObserver]]()

    public static func post(_ event: Event) {
        for notificationName in shared.notificationNames(from: event, isStrict: false) {
            NotificationCenter.default.post(name: Notification.Name(rawValue: notificationName),
                                            object: nil,
                                            userInfo: event.content)
        }
    }

    public static func subscribe(_ target: AnyObject,
                                 topic: EventsBusTopic,
                                 sender: Any? = nil,
                                 source: String? = nil,
                                 subject: String? = nil,
                                 handler: @escaping ((Notification?) -> Void)) {
        subscribe(target,
                  name: topic.description,
                  sender: sender,
                  source: source,
                  subject: subject,
                  handler: handler)
    }

    public static func subscribe(_ target: AnyObject,
                                 name: String,
                                 sender: Any? = nil,
                                 source: String? = nil,
                                 subject: String? = nil,
                                 handler: @escaping ((Notification?) -> Void)) {
        let id = UInt(bitPattern: ObjectIdentifier(target))

        let notificationNames = shared.notificationNames(withType: name, subject: subject, source: source)
        for notificationName in notificationNames {
            let observer = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: notificationName),
                                                                  object: sender,
                                                                  queue: OperationQueue.main,
                                                                  using: handler)
            let namedObserver = NamedObserver(observer: observer, name: notificationName)

            shared.queue.sync {
                if let namedObservers = shared.cache[id] {
                    shared.cache[id] = namedObservers + [namedObserver]
                } else {
                    shared.cache[id] = [namedObserver]
                }
            }
        }

        shared.logger?.debugLog(message: EventsBusLogs.subscribed.message,
                                category: EventsBusLogs.subscribed.category,
                                data: ["topic": name])
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

    public static func unsubscribe(_ target: AnyObject,
                                   type: String,
                                   source: String? = nil,
                                   subject: String? = nil) {
        let id = UInt(bitPattern: ObjectIdentifier(target))
        let center = NotificationCenter.default
        let notificationNames = shared.notificationNames(withType: type,
                                                         subject: subject,
                                                         source: source)

        shared.queue.sync {
            if let namedObservers = shared.cache[id] {
                for name in notificationNames {
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
        }

        shared.logger?.debugLog(message: EventsBusLogs.unsubscribed.message,
                                category: EventsBusLogs.unsubscribed.category,
                                data: ["notification_names": notificationNames,
                                       "target": String(describing: shared.getType(of: target))])
    }

    func notificationNames(from event: Event, isStrict: Bool = true) -> [String] {
        return notificationNames(withType: event.type, subject: event.subject, source: event.source, isStrict: isStrict)
    }

    func notificationNames(withType type: String, subject: String? = nil, source: String? = nil, isStrict: Bool = true) -> [String] {
        var notificationNames: [String] = []
        var notificationName = type
        
        if isStrict == false { //add notification name for type only
            notificationNames.append(notificationName)
        }
        
        if let subject = subject {
            notificationName += "." + subject
            if isStrict == false { //add notification name for subject
                notificationNames.append(notificationName)
            }
        }
        
        if let source = source {
            notificationName += "." + source.md5()
            notificationNames.append(notificationName)
        }
        
        //add built notification name if not added
        if notificationNames.contains(notificationName) == false {
            notificationNames.append(notificationName)
        }
        
        return notificationNames
    }

    func getType(of target: AnyObject) -> String {
        return String(describing: type(of: target))
    }
}
