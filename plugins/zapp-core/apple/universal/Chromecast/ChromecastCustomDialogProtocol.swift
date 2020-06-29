//
//  ChromecastCustomDialogProtocol.swift
//  ZappCore
//
//  Created by Alex Zchut on 4/12/2020
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation

public protocol ChromecastCustomDialogProtocol {
    func showDialog()
    func dismissDialog()
    func getPlayerNavigation() -> UIViewController
    func getMiniPlayerNavigation() -> UIViewController
}
