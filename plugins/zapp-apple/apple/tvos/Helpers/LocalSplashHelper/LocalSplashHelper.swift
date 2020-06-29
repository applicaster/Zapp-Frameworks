//
//  LocalSplashHelper.swift
//  ZappApple
//
//  Created by Alex Zchut on 16/02/2020.
//  Copyright © 2017 Applicaster Ltd. All rights reserved.
//

import Foundation

public class LocalSplashHelper:NSObject {
    public class func localSplashImage(for presentingViewController: UIViewController) -> UIImage? {
        return UIImage(named: AssetsKeys.splashImageKey)
    }
}
