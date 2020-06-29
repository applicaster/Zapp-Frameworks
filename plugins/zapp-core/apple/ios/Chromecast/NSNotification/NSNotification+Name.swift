//
//  NSNotification+Name.swift
//  ZappCore
//
//  Created by Alex Zchut on 11/04/2020.
//

public extension NSNotification.Name {
    static let chromecastSessionWillStart = Notification.Name("ChromecastSessionWillStart")
    static let chromecastSessionDidStart = Notification.Name("ChromecastSessionDidStart")
    static let chromecastCastSessionDidStart = Notification.Name("ChromecastCastSessionDidStart")
    static let chromecastSessionDidEnd = Notification.Name("ChromecastSessionDidEnd")
    static let chromecastSessionWillEnd = Notification.Name("ChromecastSessionWillEnd")
    static let chromecastStartedPlaying = Notification.Name("ChromecastStartedPlaying")
    static let chromecastPlayingError = Notification.Name("chromecastPlayingError")
    static let chromecastPlayerWasMinimized = Notification.Name("chromecastPlayerWasMinimized")
    static let chromecastManagerMiniPlayerVisibilityChange = Notification.Name("kChromecastManagerMiniPlayerVisibilityChangeNotification")
}
