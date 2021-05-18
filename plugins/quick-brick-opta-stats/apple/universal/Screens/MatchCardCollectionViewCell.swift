//
//  MatchCardCollectionViewCell.swift
//  CopaAmericaStatsScreenPlugin
//
//  Created by Jesus De Meyer on 3/13/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import UIKit

class MatchCardCollectionViewCell: UICollectionViewCell {
    @IBOutlet var matchView: MatchView!

    var matchStat: MatchStatsCard? {
        didSet {
            matchView.matchStat = matchStat
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        matchView.reset()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        matchView.setNeedsLayout()
        matchView.setNeedsUpdateConstraints()
        setNeedsUpdateConstraints()
    }
}
