//
//  SplashViewController.swift
//  ZappTvOS
//
//  Created by Anton Kononenko on 11/13/18.
//  Copyright © 2018 Applicaster LTD. All rights reserved.
//

import AVKit
import UIKit
import XrayLogger
import ZappCore

extension SplashViewController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIDevice.current.userInterfaceIdiom == .pad ? .landscapeLeft : .portrait
    }
}
