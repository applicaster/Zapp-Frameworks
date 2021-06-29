//
//  RootController+FacadeConnectorLocalNotificationProtocol.swift
//  ZappApple
//
//  Created by Anton Kononenko on 3/13/20.
//

import Foundation
import ZappCore

extension RootController: FacadeConnectorLocalNotificationProtocol {
    var errorDomainNoPluginExist: String {
        return "LOCAL_NOTIFICATION_PLUGIN_NOT_EXISTS"
    }

    public func cancel(for identifiers: [String]?,
                       completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let localNotificationManager = pluginsManager.localNotificationManager else {
            completion(.failure(NSError(domain: errorDomainNoPluginExist,
                                        code: 0,
                                        userInfo: nil)))
            return
        }
        localNotificationManager.cancel(for: identifiers,
                                        completion: completion)
    }

    public func cancelLocalNotifications(_ identifiers: [String]?,
                                         completion: @escaping (Bool, Error?) -> Void) {
        cancel(for: identifiers) { result in
            switch result {
            case let .success(value):
                completion(value, nil)
            case let .failure(error):
                completion(false, error)
            }
        }
    }

    public func present(with payload: [AnyHashable: Any],
                        completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let localNotificationManager = pluginsManager.localNotificationManager else {
            completion(.failure(NSError(domain: errorDomainNoPluginExist,
                                        code: 0,
                                        userInfo: nil)))
            return
        }
        localNotificationManager.present(with: payload,
                                         completion: completion)
    }

    public func presentLocalNotification(_ payload: [AnyHashable: Any],
                                         completion: @escaping (Bool, Error?) -> Void) {
        present(with: payload) { result in
            switch result {
            case let .success(value):
                completion(value, nil)
            case let .failure(error):
                completion(false, error)
            }
        }
    }
}
