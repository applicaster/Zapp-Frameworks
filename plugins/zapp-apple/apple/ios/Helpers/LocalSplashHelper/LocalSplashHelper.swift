//
//  LocalSplashHelper.swift
//  ZappApple
//
//  Created by Anton Kononenko on 07/02/2017.
//  Copyright © 2017 Applicaster Ltd. All rights reserved.
//

import Foundation
import XrayLogger

public class LocalSplashHelper: NSObject {
    enum FilePostfixForSize: String {
        case iphone_2x = "_phone_2x"
        case iphone_3x = "_phone_3x"
        case ipad = "_pad_1x"
        case ipad_2x = "_pad_2x"
    }

    public class func localBackgroundVideoNameForScreenSize() -> String? {
        let baseFileName = "launch_video"
        if UIDevice.current.userInterfaceIdiom == .pad {
            if UIScreen.main.scale >= 2.0 {
                return baseFileName + FilePostfixForSize.ipad_2x.rawValue
            } else {
                return baseFileName + FilePostfixForSize.ipad.rawValue
            }
        } else if UIDevice.current.userInterfaceIdiom == .phone {
            if UIScreen.main.scale >= 3.0 {
                return baseFileName + FilePostfixForSize.iphone_3x.rawValue
            } else {
                return baseFileName + FilePostfixForSize.iphone_2x.rawValue
            }
        }

        return nil
    }

    private class func fileExist(fileName: String, fileExtension: String) -> Bool {
        return (Bundle.main.path(forResource: fileName,
                                 ofType: fileExtension) != nil) ? true : false
    }
}
