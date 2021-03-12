//
//  NetworkRequestsIgnoreContentCell.swift
//  QuickBrickXray
//
//  Created by Alex Zchut on 02/25/21.
//

import Foundation
import XrayLogger

class NetworkRequestsIgnoreContentCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }

    func update(title: String ) {
        titleLabel.text = title
    }
}
