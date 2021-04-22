//
//  LocalizedLabel.swift
//  CopaAmericaStatsScreenPluginDEMO
//
//  Created by Jesus De Meyer on 5/17/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import UIKit

class LocalizedLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        localize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        localize()
    }

    fileprivate func localize() {
        if let text = self.text {
            self.text = Localized.getLocalizedString(from: text)
        }
    }
}
