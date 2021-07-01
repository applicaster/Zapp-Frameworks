//
//  KnockoutGroupCardsViewController.swift
//  CopaAmericaStatsScreenPlugin
//
//  Created by Alex Zchut on 7/1/21.
//  Copyright © 2021 Applicaster. All rights reserved.
//

import MBProgressHUD
import RxSwift
import UIKit

class KnockoutGroupCardsViewController: ViewControllerBase {
    static let storyboardID = "KnockoutGroupCardsViewController"

    var allowAllMatches: Bool = true
    var showAllMatchesAsFirstItem: Bool = true

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var tableViewGroupCards: GroupCardsTableView!
    @IBOutlet var tableViewCompletedMatches: MatchesTableView!
    @IBOutlet var collectionView: MatchesCollectionView!
    @IBOutlet var matchStatsPageControl: UIPageControl!

    fileprivate var tableViewGroupCardsCellTemplate: GroupCardTableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()

        configureGroupCardsTableView()
        configureCompletedMatchesTableView()

        collectionView.allowAllMatches = allowAllMatches
        collectionView.showAllMatchesAsFirstItem = showAllMatchesAsFirstItem
        collectionView.pageControl = matchStatsPageControl
        collectionView.showDottedOutline = true
        collectionView.didFinishProcessingMatchStats = { () in
            // heartbeat enabled all the time in case user is sitting in screen waiting for a match to start
            self.updateHeartbeat(liveData: nil, force: true)
            self.heartbeatBlock = { () -> Void in
                self.collectionView.refresh()
            }
        }
        collectionView.launchTeamScreenBlock = { (_ teamID: String) in
            self.showTeamScreen(teamID: teamID)
        }
        collectionView.launchAllMatchesScreenBlock = { () in
            self.showAllMatchesScreen()
        }
        collectionView.launchMatchScreenBlock = { (_ matchStat: MatchStatsCard) in
            self.showMatchDetailScreenWithStat(matchStat: matchStat)
        }

        matchStatsPageControl.isHidden = true

        collectionView.setup()
    }

    // MARK: -

    fileprivate func configureGroupCardsTableView() {
        tableViewGroupCards.setup(with: self)
        tableViewGroupCards.isScrollEnabled = false

    }
    
    fileprivate func configureCompletedMatchesTableView() {
        tableViewCompletedMatches.setup(with: self,
                                        showCompletedMatchesOnly: true)
        tableViewCompletedMatches.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        tableViewCompletedMatches.isScrollEnabled = false

    }
}
