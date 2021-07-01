//
//  MatchesTableView.swift
//  OptaStats
//
//  Created by Alex Zchut on 01/07/2021.
//

import Foundation
import MBProgressHUD
import RxSwift

class MatchesTableView: UITableView {
    @IBOutlet var heightConstraint: NSLayoutConstraint?

    let bag = DisposeBag()
    var teamID: String?
    var parent: ViewControllerBase?
    var showCompletedMatchesOnly: Bool = false

    fileprivate var matchDates = [MatchDate]()
    fileprivate var matches = [MatchDetail]()
    fileprivate var matchDetailForMatchId = [String: MatchStatsCard]()

    lazy var allMatchesCardViewModel: AllMatchesCardViewModel = {
        AllMatchesCardViewModel()
    }()

    func setup(with parent: ViewControllerBase?,
               teamID: String? = nil,
               showCompletedMatchesOnly: Bool = false) {
        self.parent = parent
        self.teamID = teamID
        self.showCompletedMatchesOnly = showCompletedMatchesOnly
        delegate = self
        dataSource = self
        clipsToBounds = false

        register(UINib(nibName: "MatchListingTableViewCell",
                       bundle: Bundle(for: classForCoder)),
                 forCellReuseIdentifier: "MatchListingTableViewCell")
        
        subscribe()
        allMatchesCardViewModel.fetch()
    }

    fileprivate func subscribe() {
        allMatchesCardViewModel.isLoading.asObservable()
            .subscribe(onNext: { isLoading in
                if isLoading {
                } else {
                }
            }, onError: { _ in

            }).disposed(by: bag)

        allMatchesCardViewModel.matchesCard.asObservable().subscribe(onNext: { [unowned self] _ in
            if let matches = self.allMatchesCardViewModel.matchesCard.value?.matches {
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
                    self.matches = filteredMatches
                } else {
                    if showCompletedMatchesOnly {
                        self.matches = matches.filter({ match in
                            guard let date = match.date else {
                                return true
                            }
                            return date < Date()
                        })
                        self.matches.reverse()
                    } else {
                        self.matches = matches
                    }
                }
            }

            self.reloadData()
            self.heightConstraint?.constant = self.contentSize.height

            if let model = self.allMatchesCardViewModel.matchesCard.value {
                var enableHeartbeat = false
                var didScroll = false
                for (index, m) in model.matches.enumerated() {
                    if let date = m.date, Helpers.isDateToday(date) && didScroll == false {
                        didScroll = true
                        self.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .top)
                    }

                    if self.parent?.isLiveMatch(liveData: m.liveData) == true {
                        enableHeartbeat = true
                        break
                    }
                }
                self.parent?.updateHeartbeat(liveData: nil, force: enableHeartbeat)
                self.parent?.heartbeatBlock = { () -> Void in
                    self.allMatchesCardViewModel.fetch()
                }
            }
        }).disposed(by: bag)
    }

    fileprivate func matchStatForMatch(matchID: String, completion: @escaping (_ matchStat: MatchStatsCard?) -> Void) {
        if matchID.isEmpty { return }

        if let matchDetail = matchDetailForMatchId[matchID] {
            completion(matchDetail)
        } else {
            let matchStatsCardViewModel = MatchStatsCardViewModel(fixtureId: matchID)
            matchStatsCardViewModel.matchStatsCard.asObservable().subscribe { e in
                switch e {
                case .next:
                    if let statCard = matchStatsCardViewModel.matchStatsCard.value {
                        self.matchDetailForMatchId[matchID] = statCard
                        completion(statCard)
                    }
                case let .error(error):
                    print("Error: \(error)")
                    completion(nil)
                case .completed:
                    break
                }
            }.disposed(by: bag)

            matchStatsCardViewModel.fetch()
        }
    }
}

extension MatchesTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let match = matches[indexPath.row]

        if let matchID = match.id {
            MBProgressHUD.showAdded(to: self, animated: true)
            matchStatForMatch(matchID: matchID) { stat in
                MBProgressHUD.hide(for: self, animated: true)

                if let stat = stat {
                    self.parent?.showMatchDetailScreenWithStat(matchStat: stat)
                }
            }
        }
    }
}

extension MatchesTableView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matches.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MatchListingTableViewCell") as! MatchListingTableViewCell

        let match = matches[indexPath.row]
        cell.didTapOnTeamFlag = { [weak self] teamID in
            self?.parent?.showTeamScreen(teamID: teamID)
        }
        cell.match = match

        cell.selectionStyle = .none
        cell.clipsToBounds = false
        return cell
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200.00
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200.00
    }
}
