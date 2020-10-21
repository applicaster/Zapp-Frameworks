//
//  SplashViewController+Extensions.swift
//  ZappApple
//
//  Created by Anton Kononenko on 10/19/20.
//  Copyright © 2020 Applicaster LTD. All rights reserved.
//

import UIKit

extension SplashViewController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        let ipadOrientation = FeaturesCustomization.isTabletPortrait() ? [UIInterfaceOrientationMask.portrait, UIInterfaceOrientationMask.portraitUpsideDown] : UIInterfaceOrientationMask.landscape
        return UIDevice.current.userInterfaceIdiom == .pad ? ipadOrientation : .portrait
    }
}
