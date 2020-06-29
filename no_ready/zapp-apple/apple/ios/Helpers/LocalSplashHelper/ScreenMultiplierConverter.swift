//
//  ScreenMultiplierConverter.swift
//  ZappApple
//
//  Created by Anton Kononenko on 17/01/2017.
//  Copyright © 2017 Anton Kononenko. All rights reserved.
//

import Foundation
import UIKit

open class ScreenMultiplierConverter:NSObject {
    private static let iPhone_667h = "LaunchImage-800-667h"
    private static let iPhone_736h = "LaunchImage-800-Portrait-736h"
    private static let iPhone_812h = "LaunchImage-1100-Portrait-2436h"
    private static let iPhone_896h = "LaunchImage-1200-Portrait-1792h"
    private static let iPhone_1242h = "LaunchImage-1200-Portrait-2688h"
    private static let iPad_1366h  = "Default-1366h"

    private static let filesToDisableZoomMode = [iPhone_667h, iPhone_736h, iPhone_812h, iPhone_896h, iPhone_896h, iPhone_1242h]
    private static var isZoomModeDisabled:Bool = {
        var retVal = true

        for file in filesToDisableZoomMode {
            let result = UIImage(named: file) != nil ? true : false
            if result == false {
                retVal = false
                break
            }
        }

        let result = Bundle.main.path(forResource: iPad_1366h,
                                      ofType: "png") != nil ? true : false
        if result == false {
            retVal = false
        }

        return retVal
    }()

    static let iPhoneMinPortraitWidth:CGFloat = 320.0
    static let iPadMinPortraitWidth:CGFloat = 768.0

    public class func convertedValueForScreenMultiplier(value:CGFloat) -> CGFloat {
        let multiplier = screenMultiplier()
        return (value * multiplier).rounded(.down)
    }

    open class func screenMultiplier() -> CGFloat {
        var retVal:CGFloat = 1.0
        if isZoomModeDisabled {
            let deviceRealWidth = deviceWidth()

            if UIDevice.current.userInterfaceIdiom == .pad {
                retVal = deviceRealWidth / iPadMinPortraitWidth
            } else {
                retVal = deviceRealWidth / iPhoneMinPortraitWidth
            }
        }
        return retVal
    }

    public class func deviceWidth() -> CGFloat {
        var retVal:CGFloat = 0
        let screenBounds = UIScreen.main.bounds
        let statusBarOrientation = UIApplication.shared.statusBarOrientation
        if statusBarOrientation.isPortrait {
            retVal = screenBounds.width
        } else if statusBarOrientation.isLandscape {
            retVal = screenBounds.height
        }

        return retVal
    }

    public class func deviceHeight() -> CGFloat {
        var retVal:CGFloat = 0
        let screenBounds = UIScreen.main.bounds
        let statusBarOrientation = UIApplication.shared.statusBarOrientation
        if statusBarOrientation.isPortrait {
            retVal = screenBounds.height
        } else if statusBarOrientation.isLandscape {
            retVal = screenBounds.width
        }

        return retVal
    }
}
