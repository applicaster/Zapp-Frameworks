//
//  NavigationController.swift
//  OptaStats
//
//  Created by Alex Zchut on 15/04/2021.
//

import Foundation

class NavigationController: UINavigationController, UIAdaptivePresentationControllerDelegate {
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
