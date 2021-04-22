//
//  TeamNextMatchesTableViewCell.swift
//  CopaAmericaStatsScreenPlugin
//
//  Created by Jesus De Meyer on 5/21/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import UIKit

class TeamNextMatchesTableViewCell: UITableViewCell {
    @IBOutlet var collectionView: MatchesCollectionView!
    @IBOutlet var pageControl: UIPageControl!

    var teamID: String?

    var matches = [MatchStatsCard]()

    lazy var allMatchesCardViewModel: AllMatchesCardViewModel = {
        AllMatchesCardViewModel()
    }()

    override func awakeFromNib() {
        super.awakeFromNib()

        collectionView.allowAllMatches = false
        collectionView.showDottedOutline = false
        collectionView.pageControl = pageControl
        collectionView.showAllMatches = true
        collectionView.backgroundColor = .clear
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        collectionView.clipsToBounds = true

        clipsToBounds = true
        layer.cornerRadius = 15.0
    }

    func update() {
        collectionView.teamID = teamID

        collectionView.setup()
    }
}
