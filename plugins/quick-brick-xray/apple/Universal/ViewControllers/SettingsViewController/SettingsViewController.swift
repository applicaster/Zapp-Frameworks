//
//  LoggerViewController.swift
//  QickBrickXray
//
//  Created by Anton Kononenko on 7/20/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import MessageUI
import Reporter
import UIKit
import XrayLogger

protocol SettingsViewControllerProtocol: class {
    var fileLogLevelOptions: LogLevelOptions { get }
    func setFileLogLevelOptions(newLogLevelOptions: LogLevelOptions)
}

protocol SettingsViewControllerDelegate: class {
    var delegate: SettingsViewController? { get set }
}

class SettingsViewController: UITableViewController, SettingsViewControllerProtocol {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let fileLogLevel = settings.fileLogLevel,
            let fileLogLevelOptions = LogLevelOptions(rawValue: fileLogLevel.rawValue + 1) {
            self.fileLogLevelOptions = fileLogLevelOptions
        }

    }

    private(set) var fileLogLevelOptions: LogLevelOptions = .off

    func setFileLogLevelOptions(newLogLevelOptions: LogLevelOptions) {
        fileLogLevelOptions = newLogLevelOptions
        settings.fileLogLevel = fileLogLevelOptions.toLogLevel()
        applyNewSettings()
    }

    var settings: Settings = QickBrickXray.sharedInstance!.getLocalStorageSettings()

    func applyNewSettings() {
        tableView.reloadData()
        QickBrickXray.sharedInstance?.applyCustomSettings(settings: settings)
    }
}

extension SettingsViewController {
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return SettingsHelper.numberOfItemsInSection(section: section)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsHelper.numberOfSections(settings: settings)
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = SettingsHelper.cellData(for: indexPath)!

        let cell = tableView.dequeueReusableCell(withIdentifier: cellData.cellIdentifier,
                                                 for: indexPath)
        if cellData.cellIdentifier == switchCellIndentifier,
            let cell = cell as? SwitchCell {
            var enabled = false
            if SettingsIndexesHelper.isCustomSettingsEnabled(in: indexPath) {
                enabled = settings.customSettingsEnabled
            } else if SettingsIndexesHelper.isShortcutAccessEnabled(in: indexPath) {
                enabled = settings.shortcutEnabled
            }

            cell.update(title: cellData.title,
                        enabled: enabled,
                        indexPath: indexPath,
                        delegate: self)
        } else if let cell = cell as? LogLevelSelectCell {
            cell.update(title: cellData.title,
                        value: fileLogLevelOptions)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView,
                            titleForFooterInSection section: Int) -> String? {
        let section = SettingsHelper.settingsDataSource[section]
        return section.footterText
    }

    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath,
                              animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?) {
        if let logLevelViewController = segue.destination as? LogLevelViewController {
            logLevelViewController.delegate = self
        }
    }
}

extension SettingsViewController: SwitchCellDelegate {
    func switcherDidChange(value: Bool,
                           indexPath: IndexPath) {
        if SettingsIndexesHelper.isCustomSettingsEnabled(in: indexPath) {
            settings.customSettingsEnabled = value
            applyNewSettings()
        } else if SettingsIndexesHelper.isShortcutAccessEnabled(in: indexPath) {
            settings.shortcutEnabled = value
            applyNewSettings()
        }
    }
}
