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

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            currentItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

    @IBAction func addItem(_ sender: Any) {
        let alert = UIAlertController(title: "New Domain", message: "", preferredStyle: .alert)

        let saveAction = UIAlertAction(title: "Add", style: .default) { [unowned self] _ in
            guard let textField = alert.textFields?.first,
                  let newItem = textField.text else {
                return
            }

            currentItems.append(newItem)
            self.tableView.reloadData()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .default)

        alert.addTextField()

        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }
}
