//
//  FacadeConnectorChromecastProtocol.swift
//  ZappCore
//
//  Created by Alex Zchut on 13/04/2020.
//

import Foundation


@objc public protocol FacadeConnectorChromecastProtocol {
    var isEnabled: Bool { get }
    var isSynced: Bool { get }
    var isReachableViaWiFi: Bool { get }
    var canShowPlayerBeforeCastSync: Bool { get }
    var extendedPlayerViewController: UIViewController? { get}
    var inlinePlayerViewController: UIViewController? { get}
    var miniPlayerViewController: UIViewController? { get}
    func addButton(to container: UIView?, key: String, color: UIColor?)
    func play(with playableItems: [NSObject], playPosition: TimeInterval, completion: ((_ success:Bool) -> Void)?)
    func showExtendedPlayer()
    func setNotificationsDelegate(_ delegate:NSObject?)
}
