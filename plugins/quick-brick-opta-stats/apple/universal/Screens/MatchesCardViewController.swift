//
//  MatchesCardViewController.swift
//  CopaAmericaStatsScreenPlugin
//
//  Created by Jesus De Meyer on 4/1/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import MBProgressHUD
import RxSwift
import UIKit

class MatchesCardViewController: ViewControllerBase {
    static let storyboardID = "MatchesCardViewController"

    var teamID: String?

    @IBOutlet var tableView: MatchesTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }

    fileprivate func configureTableView() {
        tableView.setup(with: self, teamID: teamID)
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }

    @objc func dismissMatchesCardVC() {
        if let navController = navigationController {
            if navController.viewControllers.count == 1 {
                dismiss(animated: true, completion: nil)
            } else {
                navController.popViewController(animated: true)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}
