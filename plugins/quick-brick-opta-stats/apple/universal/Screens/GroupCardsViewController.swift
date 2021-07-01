//
//  GroupCardsViewController.swift
//  CopaAmericaStatsScreenPlugin
//
//  Created by Jesus De Meyer on 3/6/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import MBProgressHUD
import RxSwift
import UIKit

class GroupCardsViewController: ViewControllerBase, GroupCardTableViewCellDelegate {
    static let storyboardID = "GroupCardsViewController"

    lazy var groupCardViewModel: GroupCardsViewModel = {
        GroupCardsViewModel()
    }()
    
    var allowAllMatches: Bool = true
    var showAllMatchesAsFirstItem: Bool = true
    let bag = DisposeBag()

    fileprivate var divisions = [Division]()
    fileprivate var cellHeightShouldBeExpanded = [Int: Bool]()
    fileprivate var expandedCellHeight: CGFloat = 0.0

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var collectionView: MatchesCollectionView!
    @IBOutlet var matchStatsPageControl: UIPageControl!

    fileprivate var tableViewCellTemplate: GroupCardTableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()

        subscribe()

        configureTableView()
        collectionView.allowAllMatches = allowAllMatches
        collectionView.showAllMatchesAsFirstItem = showAllMatchesAsFirstItem
        collectionView.pageControl = matchStatsPageControl
        collectionView.showDottedOutline = true
        collectionView.didFinishProcessingMatchStats = { () in
            // heartbeat enabled all the time in case user is sitting in screen waiting for a match to start
            self.updateHeartbeat(liveData: nil, force: true)
            self.heartbeatBlock = { () -> Void in
                self.groupCardViewModel.fetch()
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

        groupCardViewModel.fetch()

        collectionView.setup()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableViewHeightConstraint.constant = tableView.contentSize.height + (tabBarController?.tabBar.frame.height ?? 0)
    }

    // MARK: -

    fileprivate func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 130
        tableView.register(UINib(nibName: "GroupCardTableViewCell", bundle: Bundle(for: classForCoder)), forCellReuseIdentifier: "GroupCardTableViewCell")

        tableViewCellTemplate = tableView.dequeueReusableCell(withIdentifier: "GroupCardTableViewCell") as? GroupCardTableViewCell
    }

    fileprivate func subscribe() {
        groupCardViewModel.isLoading.asObservable()
            .subscribe(onNext: { [unowned self] isLoading in
                if isLoading {
                    MBProgressHUD.showAdded(to: self.view, animated: true)
                } else {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
            }, onError: { [unowned self] _ in
                MBProgressHUD.hide(for: self.view, animated: true)
            }).disposed(by: bag)

        groupCardViewModel.groupCard.asObservable().subscribe(onNext: { [unowned self] _ in
            self.processGroupCardViewModel()
            self.tableView.reloadData()
            self.tableViewHeightConstraint.constant = self.tableView.contentSize.height
        }).disposed(by: bag)
    }

    fileprivate func processGroupCardViewModel() {
        if let model = groupCardViewModel.groupCard.value {
            if let divitions = model.stage.divisions {
                divisions = divitions.filter {
                    $0.type == "total"
                }
            }
        }
    }

    fileprivate func saveCellExpandedState(index: Int) {
        if let currentVal = cellHeightShouldBeExpanded[index] {
            cellHeightShouldBeExpanded[index] = !currentVal
        } else {
            cellHeightShouldBeExpanded[index] = true
        }
    }
}

// MARK: -

extension GroupCardsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("row selected")
    }
}

extension GroupCardsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return divisions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCardTableViewCell") as! GroupCardTableViewCell

        let division = divisions[indexPath.row]
        cell.tag = indexPath.row
        cell.didTapOnTeamFlag = { [weak self] teamId in
            self?.showTeamScreen(teamID: teamId)
        }
        cell.didTapOnToggleExpand = { [weak self] index in
            self?.saveCellExpandedState(index: index)
        }
        cell.division = division
        cell.cellDelegate = self
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewCellTemplate.cellHeight
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let cell = tableView.cellForRow(at: indexPath) as? GroupCardTableViewCell {
            if cell.cellHeight > tableViewCellTemplate.cellHeight {
                expandedCellHeight = cell.cellHeight
            }
        }

        if let expanded = cellHeightShouldBeExpanded[indexPath.row] {
            if expanded {
                view.setNeedsLayout()
                return expandedCellHeight
            } else {
                view.setNeedsLayout()
                return tableViewCellTemplate.cellHeight
            }
        }

        view.setNeedsLayout()
        return tableViewCellTemplate.cellHeight
    }

    // MARK: -

    func groupCardTableViewCellUpdateExpanding(cell: GroupCardTableViewCell) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}
