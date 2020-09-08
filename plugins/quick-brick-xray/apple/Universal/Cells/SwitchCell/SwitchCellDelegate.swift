//
//  CellDelegate.swift
//  QickBrickXray
//
//  Created by Anton Kononenko on 9/6/20.
//

import Foundation
import XrayLogger

protocol SwitchCellDelegate: class {
    func switcherDidChange(value: Bool,
                           indexPath: IndexPath)
}
