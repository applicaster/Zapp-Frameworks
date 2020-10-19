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
        return UIDevice.current.userInterfaceIdiom == .pad ? .landscapeLeft : .portrait
    }
}
