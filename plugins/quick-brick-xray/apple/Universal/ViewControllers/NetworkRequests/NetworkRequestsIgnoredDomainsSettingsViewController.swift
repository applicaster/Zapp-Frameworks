//
//  LogLevelViewController.swift
//  QuickBrickXray
//
//  Created by Alex Zchut on 02/25/21.
//  Copyright © 2021 Applicaster. All rights reserved.
//

import Foundation
import XrayLogger
class NetworkRequestsIgnoredDomainsSettingsViewController: UITableViewController, SettingsViewControllerDelegate {
    var delegate: SettingsViewController?
    var currentItems: [String] {
        get {
            return delegate?.networkRequestsIgnoredDomains ?? []
        }
        set {
            delegate?.setNetworkRequestsIgnoredDomains(domains: newValue)
        }
    }

    let cellIdentifier = "IgnoredDomainsCellIndentifier"

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension NetworkRequestsIgnoredDomainsSettingsViewController {
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
