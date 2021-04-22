//
//  MatchesCardViewController.swift
//  CopaAmericaStatsScreenPlugin
//
//  Created by Jesus De Meyer on 4/1/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import MBProgressHUD
import RxSwift
import UIKit

class MatchesCardViewController: ViewControllerBase {
    static let storyboardID = "MatchesCardViewController"

    let bag = DisposeBag()

    lazy var allMatchesCardViewModel: AllMatchesCardViewModel = {
        AllMatchesCardViewModel()
    }()

    var teamID: String?

    fileprivate var matchDates = [MatchDate]()
    fileprivate var matches = [MatchDetail]()
    fileprivate var matchDetailForMatchId = [String: MatchStatsCard]()

    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        subscribe()
        configureTableView()

        allMatchesCardViewModel.fetch()
    }

    fileprivate func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.clipsToBounds = false
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        tableView.register(UINib(nibName: "MatchListingTableViewCell", bundle: Bundle(for: classForCoder)), forCellReuseIdentifier: "MatchListingTableViewCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
                    self.matches = matches
                }
            }

            self.tableView.reloadData()

            if let model = self.allMatchesCardViewModel.matchesCard.value {
                var enableHeartbeat = false
                var didScroll = false
                for (index, m) in model.matches.enumerated() {
                    if let date = m.date, Helpers.isDateToday(date) && didScroll == false {
                        didScroll = true
                        self.tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .top)
                    }

                    if self.isLiveMatch(liveData: m.liveData) {
                        enableHeartbeat = true
                        break
                    }
                }
                self.updateHeartbeat(liveData: nil, force: enableHeartbeat)
                self.heartbeatBlock = { () -> Void in
                    self.allMatchesCardViewModel.fetch()
                }
            }
        }).disposed(by: bag)
    }

    @objc func dismissMatchesCardVC() {
        if let navController = navigationController {
            if navController.viewControllers.count == 1 {
                dismiss(animated: true, completion: nil)
            } else {
                navController.popViewController(animated: true)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
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

extension MatchesCardViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let match = matches[indexPath.row]

        if let matchID = match.id {
            MBProgressHUD.showAdded(to: view, animated: true)
            matchStatForMatch(matchID: matchID) { stat in
                MBProgressHUD.hide(for: self.view, animated: true)

                if let stat = stat {
                    self.showMatchDetailScreenWithStat(matchStat: stat)
                }
            }
        }
    }
}

extension MatchesCardViewController: UITableViewDataSource {
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
            self?.showTeamScreen(teamID: teamID)
        }
        cell.match = match

        /* if let matchID = match.id {
             if let matchDetail = self.matchDetailForMatchId[matchID] {
                 cell.matchDetail = matchDetail
             } else {
                 let operation = BlockOperation {
                     let matchStatsCardViewModel = MatchStatsCardViewModel(fixtureId: matchID)
                     matchStatsCardViewModel.matchStatsCard.asObservable().subscribe { e in
                         switch e {
                         case .next(_):
                             if let statCard = matchStatsCardViewModel.matchStatsCard.value {
                                 cell.matchDetail = statCard
                                 self.matchDetailForMatchId[matchID] = statCard
                             }
                         case .error(let error):
                             print("Error: \(error)")
                         case .completed:
                             break
                         }
                         }.disposed(by: self.bag)

                     matchStatsCardViewModel.fetch()
                 }

                 operationQueue.addOperation(operation)
             }
         } */
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
