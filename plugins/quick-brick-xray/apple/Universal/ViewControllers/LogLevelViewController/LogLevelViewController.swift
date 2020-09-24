//
//  LogLevelViewController.swift
//  QickBrickXray
//
//  Created by Anton Kononenko on 9/6/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation
import XrayLogger
class LogLevelViewController: UITableViewController, SettingsViewControllerDelegate {
    var delegate: SettingsViewController?
    var currentLogLevel: LogLevelOptions {
        get {
            return delegate?.fileLogLevelOptions ?? .off
        }
        set {
            delegate?.setFileLogLevelOptions(newLogLevelOptions: newValue)
        }
    }

    let cellIdentifier = "LogLevelCellIndentifier"

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension LogLevelViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LogLevelOptions.listOfAllOptions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                                                 for: indexPath)

        cell.textLabel?.text = LogLevelOptions.listOfAllOptions[indexPath.row]

        cell.isSelected = currentLogLevel.rawValue == indexPath.row
        cell.isHighlighted = currentLogLevel.rawValue == indexPath.row

        if cell.isSelected {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentLogLevel = LogLevelOptions(rawValue: indexPath.row)!
        tableView.reloadData()
    }
}
