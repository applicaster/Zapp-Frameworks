//
//  LogLevelSelectCell.swift
//  QickBrickXray
//
//  Created by Anton Kononenko on 9/6/20.
//

import Foundation
import XrayLogger

class LogLevelSelectCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        valueLabel.text = nil
    }

    func update(title: String,
                value: LogLevelOptions) {
        titleLabel.text = title
        valueLabel.text = value.toString()
        valueLabel.textColor = value.toColor()
    }
}
