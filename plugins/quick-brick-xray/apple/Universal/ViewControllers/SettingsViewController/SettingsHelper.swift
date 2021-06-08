//
//  SettingsHelper.swift
//  QuickBrickXray
//
//  Created by Anton Kononenko on 7/20/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation

let switchCellIndentifier = "SwitchCellIdentifier"
let logLevelCellIndentifier = "LogLevelCellIdentifier"
let networkRequestsIgnoreExtensionsCellIdentifier = "NetworkRequestsIgnoreExtensionsCellIdentifier"
let networkRequestsIgnoreDomainsCellIdentifier = "NetworkRequestsIgnoreDomainsCellIdentifier"

struct SettingsIndexesHelper {
    static func isCustomSettingsEnabled(in indexPath: IndexPath) -> Bool {
        return indexPath == IndexPath(row: 0, section: 0)
    }

    static func isShortcutAccessEnabled(in indexPath: IndexPath) -> Bool {
        return indexPath == IndexPath(row: 0, section: 1)
    }

    static func isFileLogLevel(in indexPath: IndexPath) -> Bool {
        return indexPath == IndexPath(row: 0, section: 2)
    }
    
    static func isXRayFloatingButtonEnabled(in indexPath: IndexPath) -> Bool {
        return indexPath == IndexPath(row: 0, section: 3)
    }
    
    static func isNetworkRequestEnabled(in indexPath: IndexPath) -> Bool {
        return indexPath == IndexPath(row: 0, section: 4)
    }
}

struct Cell {
    var title: String
    var cellIdentifier: String
}

struct Section {
    var footerText: String?
    var cells: [Cell] = []
}

class SettingsHelper {
    static var settingsDataSource: [Section] {
        let sections = [
            customSettingsData(),
            shortcutAccess(),
            fileLogLevel(),
            showXrayFloatingButton(),
            networkRequests()
        ]
        return sections
    }

    static func numberOfSections(settings: Settings) -> Int {
        let showOnlyCustomSettingsOption = 1
        return settings.customSettingsEnabled ? SettingsHelper.settingsDataSource.count : showOnlyCustomSettingsOption
    }

    static func numberOfItemsInSection(section: Int) -> Int {
        let sections = SettingsHelper.settingsDataSource
        guard sections.count > section else {
            return 0
        }
        let section = SettingsHelper.settingsDataSource[section]
        return section.cells.count
    }

    static func cellData(for indexPath: IndexPath) -> Cell? {
        let sections = SettingsHelper.settingsDataSource
        guard sections.count > indexPath.section else {
            return nil
        }

        let section = SettingsHelper.settingsDataSource[indexPath.section]
        guard section.cells.count > indexPath.row else {
            return nil
        }

        let cell = section.cells[indexPath.row]

        return cell
    }

    static func customSettingsData() -> Section {
        var customSettings = Section(footerText: "Please note: This switch will enable custom settings for logger plugin that will override plugin configuration settings and environment rules. Will take effect until will not be disabled")
        let cell = Cell(title: "Custom settings",
                        cellIdentifier: switchCellIndentifier)
        customSettings.cells.append(cell)
        return customSettings
    }

    static func shortcutAccess() -> Section {
        var shortcutAccess = Section(footerText: "Enables option to start logger from application shortcut icon.")
        let cell = Cell(title: "Shortcut access",
                        cellIdentifier: switchCellIndentifier)
        shortcutAccess.cells.append(cell)
        return shortcutAccess
    }

    static func fileLogLevel() -> Section {
        var fileLogLevel = Section(footerText: "Defines minimum log level that will be saved to log file. If Off will not save any data to local file")
        let cell = Cell(title: "File log level",
                        cellIdentifier: logLevelCellIndentifier)
        fileLogLevel.cells.append(cell)
        return fileLogLevel
    }
    
    static func showXrayFloatingButton() -> Section {
        var xRayFloatingButton = Section(footerText: "Enables appearance of XRay floating button on screen")
        let cell = Cell(title: "Show Xray floating button",
                        cellIdentifier: switchCellIndentifier)
        xRayFloatingButton.cells.append(cell)
        return xRayFloatingButton
    }
    
    static func networkRequests() -> Section {
        var networkRequestsSection = Section(footerText: "Defines Parameters for Network Requests")

        let cell = Cell(title: "Enable network requests logging",
                        cellIdentifier: switchCellIndentifier)
        networkRequestsSection.cells.append(cell)
        
        let extensionsCell = Cell(title: "Ignored Extensions",
                        cellIdentifier: networkRequestsIgnoreExtensionsCellIdentifier)
        networkRequestsSection.cells.append(extensionsCell)
        
        let domainsCell = Cell(title: "Ignored Domains",
                        cellIdentifier: networkRequestsIgnoreDomainsCellIdentifier)
        networkRequestsSection.cells.append(domainsCell)
        return networkRequestsSection
    }
}
