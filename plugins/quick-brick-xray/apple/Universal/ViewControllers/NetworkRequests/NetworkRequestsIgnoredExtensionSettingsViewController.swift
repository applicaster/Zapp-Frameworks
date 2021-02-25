//
//  NetworkRequestsIgnoredExtensionSettingsViewController.swift
//  QuickBrickXray
//
//  Created by Alex Zchut on 02/25/21.
//  Copyright © 2021 Applicaster. All rights reserved.
//

import Foundation
import XrayLogger
class NetworkRequestsIgnoredExtensionSettingsViewController: UITableViewController, SettingsViewControllerDelegate {
    var delegate: SettingsViewController?
    var currentItems: [String] {
        get {
            return delegate?.networkRequestsIgnoredExtensions ?? []
        }
        set {
            delegate?.setNetworkRequestsIgnoredExtensions(extensions: newValue)
        }
    }

    let cellIdentifier = "IgnoredExtensionsCellIndentifier"

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension NetworkRequestsIgnoredExtensionSettingsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                                                 for: indexPath)

        cell.textLabel?.text = currentItems[indexPath.row]

        return cell
    }
}
