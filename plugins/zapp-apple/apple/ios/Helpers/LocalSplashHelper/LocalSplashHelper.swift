//
//  LocalSplashHelper.swift
//  ZappApple
//
//  Created by Anton Kononenko on 07/02/2017.
//  Copyright © 2017 Applicaster Ltd. All rights reserved.
//

import Foundation
import XrayLogger
// iPhone 7 Plus
//    (0.0, 0.0, 414.0, 736.0)
//    (0.0, 0.0, 1242.0, 2208.0)

// iPhone 6
//    (0.0, 0.0, 375.0, 667.0)
//    (0.0, 0.0, 750.0, 1334.0)

// iPhone SE, iPhone 5
//    (0.0, 0.0, 320.0, 568.0)
//    (0.0, 0.0, 640.0, 1136.0)

// iPhone 4s
//    (0.0, 0.0, 320.0, 480.0)
//    (0.0, 0.0, 640.0, 960.0)

// iPad 2
//    (0.0, 0.0, 768.0, 1024.0)
//    (0.0, 0.0, 768.0, 1024.0)

// iPad Retina, Air, Air2, Pro(9.7)
//    (0.0, 0.0, 768.0, 1024.0)
//    (0.0, 0.0, 1536.0, 2048.0)

// iPad Pro(12.9)
//    (0.0, 0.0, 1024.0, 1366.0)
//    (0.0, 0.0, 2048.0, 2732.0)

// case iphone     = "local_splash"
// case iphone_568 = "Default-568h"
// case iphone_667 = "Default-667h"
// case iphone_736 = "Default-736h"
// case ipad_1024  = "Default"
// case ipad_1366  = "Default-1366h"

public class LocalSplashHelper: NSObject {
    private static let localSplashImageIphone_480 = "LaunchImage-700@2x"
    private static let localSplashImageIphone_568 = "LaunchImage-700-568h@2x"
    private static let localSplashImageIphone_667 = "LaunchImage-800-667h@2x"
    private static let localSplashImageIphone_736 = "LaunchImage-800-Portrait-736h@3x"
    private static let localSplashImageIphone_812 = "LaunchImage-1100-Portrait-2436h@3x"
    private static let localSplashImageIphone_896 = "LaunchImage-1200-Portrait-1792h@2x"
    private static let localSplashImageIphone_1242 = "LaunchImage-1200-Portrait-2688h@3x"
    private static let localSplashImageIpadNonRetina_1024 = "LaunchImage-700-Landscape~ipad"
    private static let localSplashImageIpad_1024 = "LaunchImage-700-Landscape@2x~ipad"
    private static let localSplashImageIpadPortraitNonRetina_1024 = "LaunchImage-700-Portrait~ipad"
    private static let localSplashImageIpadPortrait_1024 = "LaunchImage-700-Portrait@2x~ipad"
    private static let localSplashImageIpad_1366 = "Default-1366h"

    enum FilePostfixForSize: String {
        case none, iphone480 = ""
        case iphone568 = "-568h"
        case iphone667 = "-667h"
        case iphone736 = "-736h"
        case iphone812 = "-812h"
        case iphone896 = "-896h"
        case iphone1242 = "-1242h"

        case ipad1024_1x = "_1x-ipad"
        case ipad1024 = "-ipad"
        case ipad1024_portrait_1x = "_portrait_1x-ipad"
        case ipad1024_portrait = "_portrait-ipad"
    }

    public class func localSplashImage(for presentingViewController: UIViewController) -> UIImage? {
        let logger = Logger.getLogger(for: SplashViewControllerHelperLogs.subsystem)

        // Rotate the splash image for iPhone
        var image = UIImage(named: LocalSplashHelper.localSplashImageNameForScreenSize())

        var loggerData = ["image_name": LocalSplashHelper.localSplashImageNameForScreenSize()]

        if UIDevice.current.userInterfaceIdiom == .phone,
            let cgImage = image?.cgImage {
            switch presentingViewController.preferredInterfaceOrientationForPresentation {
            case .landscapeRight:
                loggerData["orientation"] = "right"
                image = UIImage(cgImage: cgImage, scale: 1.0, orientation: .right)
            case .landscapeLeft:
                loggerData["orientation"] = "left"
                image = UIImage(cgImage: cgImage, scale: 1.0, orientation: .left)
            default:
                break
            }
        }

        logger?.debugLog(template: AppDelegateLogs.didFinishLaunching,
                         data: loggerData)

        return image
    }

    public class func localSplashImageNameForScreenSize() -> String {
        var retVal = ""

        let devicePortraitWidth = ScreenMultiplierConverter.deviceWidth()
        let devicePortraitHeight = ScreenMultiplierConverter.deviceHeight()
        let size = UIScreen.main.bounds.size

        if UIDevice.current.userInterfaceIdiom == .pad {
            retVal = localSplashImageIpad_1024

            if size.width == 768 {
                if UIScreen.main.scale >= 2.0 {
                    retVal = localSplashImageIpadPortrait_1024
                } else {
                    retVal = localSplashImageIpadPortraitNonRetina_1024
                }
            } else {
                if UIScreen.main.scale >= 2.0 {
                    retVal = localSplashImageIpad_1024
                } else {
                    retVal = localSplashImageIpadNonRetina_1024
                }
            }

        } else if UIDevice.current.userInterfaceIdiom == .phone {
            retVal = localSplashImageIphone_568
            if devicePortraitWidth == 320 {
                if size.width == 568 || size.height == 568 {
                    retVal = localSplashImageIphone_568
                } else {
                    retVal = localSplashImageIphone_480
                }
            } else if devicePortraitWidth == 375 {
                if devicePortraitHeight == 812 {
                    retVal = localSplashImageIphone_812
                } else {
                    retVal = localSplashImageIphone_667
                }
            } else if devicePortraitWidth == 414 {
                if devicePortraitHeight == 896 {
                    if UIScreen.main.scale == 3.0 {
                        retVal = localSplashImageIphone_1242
                    } else {
                        retVal = localSplashImageIphone_896
                    }
                } else {
                    retVal = localSplashImageIphone_736
                }
            }
        }

        return retVal
    }

    public class func localSplashVideoNameForScreenSize() -> String {
        return LocalSplashHelper.localBackgroundVideoNameForScreenSize(baseFileName: "local_splash_video")
    }

    public class func localBackgroundVideoNameForScreenSize(baseFileName: String) -> String {
        var postix: FilePostfixForSize = .none

        let devicePortraitWidth = ScreenMultiplierConverter.deviceWidth()
        let devicePortraitHeight = ScreenMultiplierConverter.deviceHeight()
        let size = UIScreen.main.bounds.size

        if UIDevice.current.userInterfaceIdiom == .pad {
            postix = .ipad1024

            if devicePortraitWidth == 768 {
                if size.width == 768 {
                    if UIScreen.main.scale >= 2.0 {
                        postix = .ipad1024_portrait
                    } else {
                        postix = .ipad1024_portrait_1x
                    }
                } else {
                    if UIScreen.main.scale >= 2.0 {
                        postix = .ipad1024
                    } else {
                        postix = .ipad1024_1x
                    }
                }
            }
        } else if UIDevice.current.userInterfaceIdiom == .phone {
            postix = .iphone568

            if devicePortraitWidth == 320 {
                if size.width == 568 || size.height == 568 {
                    postix = .iphone568
                } else {
                    postix = .iphone480
                }
            } else if devicePortraitWidth == 375 {
                if devicePortraitHeight == 812 {
                    postix = .iphone812
                } else {
                    postix = .iphone667
                }

            } else if devicePortraitWidth == 414 {
                if devicePortraitHeight == 896 {
                    if UIScreen.main.scale == 3.0 {
                        postix = .iphone1242
                    } else {
                        postix = .iphone896
                    }
                } else {
                    postix = .iphone736
                }
            }
        }

        return baseFileName + postix.rawValue
    }

    private class func fileExist(fileName: String, fileExtension: String) -> Bool {
        return (Bundle.main.path(forResource: fileName,
                                 ofType: fileExtension) != nil) ? true : false
    }
}
