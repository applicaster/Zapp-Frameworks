//
//  CellDelegate.swift
//  QuickBrickXray
//
//  Created by Anton Kononenko on 9/6/20.
//

import Foundation
import XrayLogger

protocol SwitchCellDelegate: AnyObject {
    func switcherDidChange(value: Bool,
                           indexPath: IndexPath)
}
