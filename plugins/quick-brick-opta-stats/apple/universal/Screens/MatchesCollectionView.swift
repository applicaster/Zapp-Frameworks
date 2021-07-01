//
//  MatchesCollectionView.swift
//  CopaAmericaStatsScreenPlugin
//
//  Created by Jesus De Meyer on 5/21/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import RxSwift
import UIKit

class MatchesCollectionView: UICollectionView {
    lazy var matchesCardViewModel: MatchesCardViewModel = {
        MatchesCardViewModel()
    }()

    lazy var allMatchesCardViewModel: AllMatchesCardViewModel = {
        AllMatchesCardViewModel()
    }()

    var teamID: String?

    var allowAllMatches: Bool = false
    var showAllMatches: Bool = false
    var numberOfMatchesToShow: Int = OptaStats.pluginParams.numberOfMatches

    var showAllMatchesAsFirstItem: Bool = false
    var pageControl: UIPageControl?
    var showDottedOutline: Bool = true

    var didFinishProcessingMatchStats: (() -> Void)?
    var launchTeamScreenBlock: ((_ teamID: String) -> Void)?
    var launchAllMatchesScreenBlock: (() -> Void)?
    var launchMatchScreenBlock: ((_ matchStat: MatchStatsCard) -> Void)?

    fileprivate let bag = DisposeBag()

    fileprivate var matchesToProcess = 0
    fileprivate var matchesProcessed = 0
    fileprivate(set) var matchStats = [MatchStatsCard]()
    fileprivate var activityIndicatorView: UIActivityIndicatorView = {
        UIActivityIndicatorView(style: .gray)
    }()

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setup() {
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(activityIndicatorView)

        addConstraint(NSLayoutConstraint(item: activityIndicatorView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX
                                         , multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: activityIndicatorView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY
                                         , multiplier: 1.0, constant: 0.0))

        configureCollectionView()
        if let _ = teamID {
            subscribeAllMatches()
        } else {
            subscribe()
        }
    }

    fileprivate func configureCollectionView() {
        delegate = self
        dataSource = self
        register(UINib(nibName: "MatchCardCollectionViewCell", bundle: Bundle(for: classForCoder)), forCellWithReuseIdentifier: "MatchCardCollectionViewCell")

        if allowAllMatches {
            register(UINib(nibName: "ViewAllMatchesCollectionViewCell", bundle: Bundle(for: classForCoder)), forCellWithReuseIdentifier: "ViewAllMatchesCollectionViewCell")
        }

        alpha = 0.0
    }

    fileprivate func subscribe() {
        matchesCardViewModel.numberOfMatchesToShow = numberOfMatchesToShow
        matchesCardViewModel.matchesForDisplay.asObservable().subscribe { e in
            switch e {
            case .next:
                UIView.animate(withDuration: 0.25, animations: {
                    self.alpha = 1.0
                })

                let matches = self.showAllMatches ? self.matchesCardViewModel.allMatches : self.matchesCardViewModel.matchesForDisplay.value
                self.matchesToProcess = matches.count
                self.matchesProcessed = 0

                if self.activityIndicatorView.isAnimating {
                    if matches.count > 0 {
                        for match in matches {
                            guard let matchID = match.id else { continue }
                            self.processMatchStats(matchID: matchID)
                        }
                    }
                    else {
                        self.activityIndicatorView.stopAnimating()
                        self.didFinishProcessingMatchStats?()
                        self.removeFromSuperview()
                    }
                }
                else {
                    self.activityIndicatorView.startAnimating()
                }

            case let .error(error):
                print("Error: \(error)")
            case .completed:
                self.didFinishProcessingMatchStats?()
                break
            }
        }.disposed(by: bag)

        refresh()
    }

    fileprivate func subscribeAllMatches() {
        allMatchesCardViewModel.isLoading.asObservable()
            .subscribe(onNext: { isLoading in
                if isLoading {
                    // MBProgressHUD.showAdded(to: self.view, animated: true)
                } else {
                    // MBProgressHUD.hide(for: self.view, animated: true)
                }
            }, onError: { _ in
                // MBProgressHUD.hide(for: self.view, animated: true)
            }).disposed(by: bag)

        allMatchesCardViewModel.matchesCard.asObservable().subscribe(onNext: { [unowned self] _ in
            if let matches = self.allMatchesCardViewModel.matchesCard.value?.matches {
                var allMatches = [MatchDetail]()

                if let teamID = self.teamID {
                    var filteredMatches = [MatchDetail]()
                    for match in matches {
                        if let contestants = match.contestants {
                            for c in contestants {
                                if let id = c.id, id == teamID {
                                    filteredMatches.append(match)
                                }
                            }
                        }
                    }
                    allMatches = filteredMatches
                } else {
                    allMatches = matches
                }

                UIView.animate(withDuration: 0.25, animations: {
                    self.alpha = 1.0
                })
                if !self.activityIndicatorView.isAnimating {
                    self.activityIndicatorView.startAnimating()
                }

                self.matchesToProcess = allMatches.count
                self.matchesProcessed = 0

                for match in allMatches {
                    guard let matchID = match.id else { continue }
                    self.processMatchStats(matchID: matchID)
                }
            }
        }).disposed(by: bag)

        refresh()
    }

    fileprivate func processMatchStats(matchID: String) {
        let matchStatsCardViewModel = MatchStatsCardViewModel(fixtureId: matchID)

        matchStatsCardViewModel.matchStatsCard.asObservable().subscribe { e in
            switch e {
            case .next:
                if let statCard = matchStatsCardViewModel.matchStatsCard.value {
                    self.matchStats.append(statCard)

                    self.matchesProcessed += 1

                    if self.matchesProcessed >= self.matchesToProcess {
                        if Helpers.tournamentFinished {
                            self.matchStats = self.matchStats.sorted {
                                $0.matchInfo.date ?? Date() > $1.matchInfo.date ?? Date()
                            }
                        } else {
                            self.matchStats = self.matchStats.sorted {
                                $0.matchInfo.date ?? Date() < $1.matchInfo.date ?? Date()
                            }
                        }
                        self.activityIndicatorView.stopAnimating()
                        self.pageControl?.isHidden = self.matchStats.count <= 1
                        self.pageControl?.numberOfPages = self.matchStats.count

                        if self.allowAllMatches {
                            self.pageControl?.numberOfPages += 1
                        }

                        self.didFinishProcessingMatchStats?()
                        self.reloadData()
                        self.scrollToUpNextMatchIfAvailable()
                    }
                }
            case let .error(error):
                print("Error: \(error)")
            case .completed:
                break
            }
        }.disposed(by: bag)

        matchStatsCardViewModel.fetch()
    }

    fileprivate func scrollToUpNextMatchIfAvailable() {
        var scrollToIndex: Int = 0
        mainLoop: for (index, match) in matchStats.enumerated() {
            if let status = match.liveData.matchDetails?.matchStatus, status.uppercased() != "PLAYED" {
                scrollToIndex = index
                break mainLoop
            }
        }

        let indexPath = IndexPath(item: scrollToIndex, section: 0)
        scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }

    func refresh() {
        matchStats.removeAll()

        if let _ = teamID {
            allMatchesCardViewModel.fetch()
        } else {
            matchesCardViewModel.fetch()
        }
    }
    
    func hideActivityIndicator() {
        self.activityIndicatorView.stopAnimating()
    }
    
    func isAllMatchesItem(with indexPath: IndexPath) -> Bool {
        var retValue = false
        if allowAllMatches {
            if indexPath.row == 0,
               showAllMatchesAsFirstItem == true {
                retValue = true
            }
            else if indexPath.row == matchStats.count,
                    showAllMatchesAsFirstItem == false {
                retValue = true
            }
        }
        
        return retValue
    }
    
    var adjustIndexPathRow: Int {
        return allowAllMatches ? (showAllMatchesAsFirstItem ? 1 : 0) : 0
    }
}

extension MatchesCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard isAllMatchesItem(with: indexPath) else {
            return
        }
        launchAllMatchesScreenBlock?()
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updatePage(scrollView)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updatePage(scrollView)
    }

    func updatePage(_ scrollView: UIScrollView) {
        if scrollView == self {
            let page = (scrollView.contentOffset.x + scrollView.frame.width) / scrollView.frame.width
            pageControl?.currentPage = Int(page) - 1
        }
    }
}

extension MatchesCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if teamID == nil {
            if !matchesCardViewModel.finishedFetchingUpcomingMatches { return 0 }
        }

        var count = matchStats.count
        if allowAllMatches {
            count += 1
        }
        return count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell
        
        if isAllMatchesItem(with: indexPath) {
            let newCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ViewAllMatchesCollectionViewCell", for: indexPath) as! ViewAllMatchesCollectionViewCell
            cell = newCell
        }
        else {
            let index = indexPath.row - adjustIndexPathRow
            let newCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MatchCardCollectionViewCell", for: indexPath) as! MatchCardCollectionViewCell
            let matchStat = matchStats[index]
            newCell.matchView.didTapOnTeamFlag = { [weak self] teamId in
                self?.launchTeamScreenBlock?(teamId)
            }
            newCell.matchView.didTapOnView = { [weak self] () -> Void in
                self?.launchMatchScreenBlock?(matchStat)
            }
            newCell.matchStat = matchStat
            newCell.matchView.hasDottedLines = showDottedOutline
            if !showDottedOutline {
                newCell.backgroundColor = .white
            }
            cell = newCell
        }

        cell.layoutIfNeeded()

        return cell
    }
}
