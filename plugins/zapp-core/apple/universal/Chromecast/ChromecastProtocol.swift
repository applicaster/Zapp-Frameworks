//
//  ZPChromecastProtocol.swift
//  ZappCore
//
//  Created by Alex Zchut on 4/12/2020
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation
import UIKit

public protocol ChromecastProtocol {
    var lastActiveChromecastButton: ChromecastButtonOrigin? {get set}
    var triggeredChromecastButton: ChromecastButtonOrigin? {get set}
    var containerViewEventsDelegate: Any? {get set}
    var isEnabled: Bool { get }
    func addButton(to container: UIView?, key: String, color: UIColor?)
    func prepareChromecastForUse() -> Bool
    func hasConnectedCastSession() -> Bool
    func createChromecastButton(frame:CGRect, customIcons: [String: [UIImage]]?) -> UIButton
    func createChromecastButton(frame:CGRect) -> UIButton
    func presentCastInstructionsViewControllerOnce(with castButton:UIButton)
    func defaultExpandedMediaControlsViewController() -> UIViewController?
    func getShouldPresentIntroductionScreen() -> Bool
    func hasAvailableChromecastDevices() -> Bool
    func play()
    func stop()
    func pause()
    func seek(_ playPosition: Int)
    func setVolume(_ volume: Float)
}
