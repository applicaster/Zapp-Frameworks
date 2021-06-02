//
//  LoggerViewController.swift
//  QuickBrickXray
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

    var networkRequestsIgnoredExtensions: [String] { get }
    func setNetworkRequestsIgnoredExtensions(extensions: [String])

    var networkRequestsIgnoredDomains: [String] { get }
    func setNetworkRequestsIgnoredDomains(domains: [String])
}

protocol SettingsViewControllerDelegate: class {
    var delegate: SettingsViewController? { get set }
}

class SettingsViewController: UITableViewController {
    @IBAction func close(_ sender: UIBarButtonItem) {
        let presenter = UIApplication.shared.keyWindow?.rootViewController
        presenter?.presentedViewController?.dismiss(animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let fileLogLevel = settings.fileLogLevel,
           let fileLogLevelOptions = LogLevelOptions(rawValue: fileLogLevel.rawValue + 1) {
            self.fileLogLevelOptions = fileLogLevelOptions
        }

        networkRequestsIgnoredExtensions = settings.networkRequestsIgnoredExtensions
        networkRequestsIgnoredDomains = settings.networkRequestsIgnoredDomains
    }

    private(set) var fileLogLevelOptions: LogLevelOptions = .off
    private(set) var networkRequestsIgnoredExtensions: [String] = []
    private(set) var networkRequestsIgnoredDomains: [String] = []

    var settings: Settings = QuickBrickXray.sharedInstance!.getLocalStorageSettings()

    func applyNewSettings() {
        tableView.reloadData()
        QuickBrickXray.sharedInstance?.applyCustomSettings(settings: settings)
    }
}

extension SettingsViewController: SettingsViewControllerProtocol {
    func setNetworkRequestsIgnoredExtensions(extensions: [String]) {
        networkRequestsIgnoredExtensions = extensions
        settings.networkRequestsIgnoredExtensions = extensions
        applyNewSettings()
    }

    func setNetworkRequestsIgnoredDomains(domains: [String]) {
        networkRequestsIgnoredDomains = domains
        settings.networkRequestsIgnoredDomains = domains
        applyNewSettings()
    }

    func setFileLogLevelOptions(newLogLevelOptions: LogLevelOptions) {
        fileLogLevelOptions = newLogLevelOptions
        settings.fileLogLevel = fileLogLevelOptions.toLogLevel()
        applyNewSettings()
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
            } else if SettingsIndexesHelper.isXRayFloatingButtonEnabled(in: indexPath) {
                enabled = settings.showXrayFloatingButtonEnabled
            } else if SettingsIndexesHelper.isNetworkRequestEnabled(in: indexPath) {
                enabled = settings.networkRequestEnabled
            }

            cell.update(title: cellData.title,
                        enabled: enabled,
                        indexPath: indexPath,
                        delegate: self)
        } else if let cell = cell as? LogLevelSelectCell {
            cell.update(title: cellData.title,
                        value: fileLogLevelOptions)

        } else if let cell = cell as? NetworkRequestsIgnoreContentCell {
            cell.update(title: cellData.title)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView,
                            titleForFooterInSection section: Int) -> String? {
        let section = SettingsHelper.settingsDataSource[section]
        return section.footerText
    }

    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath,
                              animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?) {
        if let controller = segue.destination as? LogLevelViewController {
            controller.delegate = self
        }

        if let controller = segue.destination as? NetworkRequestsIgnoredExtensionSettingsViewController {
            controller.delegate = self
        }

        if let controller = segue.destination as? NetworkRequestsIgnoredDomainsSettingsViewController {
            controller.delegate = self
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
        } else if SettingsIndexesHelper.isXRayFloatingButtonEnabled(in: indexPath) {
            settings.showXrayFloatingButtonEnabled = value
            applyNewSettings()
        } else if SettingsIndexesHelper.isNetworkRequestEnabled(in: indexPath) {
            presentAlertForAppReloading(newValue: value) {
                self.settings.networkRequestEnabled = value
                self.applyNewSettings()
            }
        }
    }

    fileprivate func presentAlertForAppReloading(newValue value: Bool, completion: (() -> Void)?) {
        let title = "App Reload"
        let description = "App reload is required to perform selected operation"
        let continueTitle = "Continue"
        let cancelTitle = "Cancel"

        let alert = UIAlertController(title: title,
                                      message: description,
                                      preferredStyle: .alert)

        let continueButton = UIAlertAction(title: continueTitle,
                                           style: .destructive,
                                           handler: { _ in
                                               completion?()
                                               exit(0)
                                           })

        let cancelButton = UIAlertAction(title: cancelTitle,
                                         style: .cancel,
                                         handler: { _ in
                                             alert.dismiss(animated: true, completion: {
                                                 //
                                             })
                                         })
        alert.addAction(continueButton)
        alert.addAction(cancelButton)

        present(alert,
                animated: true,
                completion: nil)
    }
}
