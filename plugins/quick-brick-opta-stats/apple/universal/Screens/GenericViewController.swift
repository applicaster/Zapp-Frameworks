//
//  GenericViewController.swift
//  CopaAmericaStatsScreenPlugin
//
//  Created by Jesus De Meyer on 3/29/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import UIKit

class GenericViewController: ViewControllerBase {
    @IBOutlet var screenNameLabel: UILabel!

    var screenType: StatsScreenTypes = .undefined

    override func viewDidLoad() {
        super.viewDidLoad()

        screenNameLabel.text = screenType.rawValue
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}
