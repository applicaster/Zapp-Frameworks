//
//  MatchDetailViewController.swift
//  CopaAmericaStatsScreenPlugin
//
//  Created by Jesus De Meyer on 4/2/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import MBProgressHUD
import RxSwift
import UIKit

class MatchDetailViewController: ViewControllerBase, UITableViewDelegate, UITableViewDataSource {
    static let storyboardID = "MatchDetailViewController"

    @IBOutlet var containerView: UIView!
    @IBOutlet var matchView: MatchView!
    @IBOutlet var goalsTableView: UITableView!
    @IBOutlet var goalsTableViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet var posetionTitleLabel: UILabel!
    @IBOutlet var posetionHomeLabel: UILabel!
    @IBOutlet var posetionHomeProgressView: UIProgressView!
    @IBOutlet var posetionImageView: UIImageView!
    @IBOutlet var posetionAwayProgressView: UIProgressView!
    @IBOutlet var posetionAwayLabel: UILabel!

    @IBOutlet var passesHeaderLabel: LocalizedLabel!
    @IBOutlet var passesHomeLabel: UILabel!
    @IBOutlet var passesHomeProgressView: UIProgressView!
    @IBOutlet var passesAwayLabel: UILabel!
    @IBOutlet var passesAwayProgressView: UIProgressView!

    @IBOutlet var cornersHomeHeaderLabel: LocalizedLabel!
    @IBOutlet var cornerHomeLabel: UILabel!
    @IBOutlet var cornersAwayHeaderLabel: LocalizedLabel!
    @IBOutlet var cornerAwayLabel: UILabel!

    @IBOutlet var goalShotsHeaderLabel: LocalizedLabel!
    @IBOutlet var goalShotsHomeLabel: UILabel!
    @IBOutlet var goalShotsHomeProgressView: UIProgressView!
    @IBOutlet var goalShotsAwayLabel: UILabel!
    @IBOutlet var goalShotsAwayProgressView: UIProgressView!

    @IBOutlet var foulsHomeHeaderLabel: LocalizedLabel!
    @IBOutlet var faulsHomeLabel: UILabel!
    @IBOutlet var yellowCardHomeView: UIView!
    @IBOutlet var yellowCardsHomeLabel: UILabel!
    @IBOutlet var redCardHomeView: UIView!
    @IBOutlet var redCardsHomeLabel: UILabel!
    @IBOutlet var foulsAwayHeaderLabel: LocalizedLabel!
    @IBOutlet var faulsAwayLabel: UILabel!
    @IBOutlet var yellowCardAwayView: UIView!
    @IBOutlet var yellowCardsAwayLabel: UILabel!
    @IBOutlet var redCardAwayView: UIView!
    @IBOutlet var redCardsAwayLabel: UILabel!

    @IBOutlet var playerFormationsView: MatchPlayerFormationView!

    @IBOutlet var homeFormationLabel: UILabel!
    @IBOutlet var awayFormationLabel: UILabel!
    @IBOutlet var playerLineupTableView: UITableView!
    @IBOutlet var playerLineupTableViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet var refereeHeaderLabel: LocalizedLabel!
    @IBOutlet var refereeLabel: UILabel!
    @IBOutlet var assistantsHeaderLabel: LocalizedLabel!
    @IBOutlet var assistant1Label: UILabel!
    @IBOutlet var assistant2Label: UILabel!

    let bag = DisposeBag()

    var matchStat: MatchStatsCard?
    var matchID = ""

    fileprivate var matchStatsCardViewModel: MatchStatsCardViewModel!
    fileprivate var goals = [Goal]()
    fileprivate var homePlayers = [Player]()
    fileprivate var homeSubstitutes = [Player]()
    fileprivate var awayPlayers = [Player]()
    fileprivate var awaySubstitutes = [Player]()

    override func viewDidLoad() {
        super.viewDidLoad()

        styleUI()
        subscribe()

        containerView.layer.cornerRadius = 9.0
        containerView.layer.shadowRadius = 10.0
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.clipsToBounds = false

        matchView.hasDottedLines = false
        matchView.matchStat = matchStat
        matchView.moreInfoImageView?.isHidden = true

        goalsTableView.delegate = self
        goalsTableView.dataSource = self
        goalsTableView.reloadData()
        goalsTableViewHeightConstraint.constant = goalsTableView.contentSize.height

        playerLineupTableView.register(UINib(nibName: "LineupTableViewCell", bundle: Bundle(for: classForCoder)), forCellReuseIdentifier: "LineupTableViewCell")
        playerLineupTableView.delegate = self
        playerLineupTableView.dataSource = self
        playerLineupTableView.reloadData()
        playerLineupTableViewHeightConstraint.constant = playerLineupTableView.contentSize.height

        yellowCardHomeView.layer.cornerRadius = 0.5
        redCardHomeView.layer.cornerRadius = 0.5
        yellowCardAwayView.layer.cornerRadius = 0.5
        redCardAwayView.layer.cornerRadius = 0.5
    }

    fileprivate func styleUI() {
        posetionTitleLabel.useBoldFont()
        posetionHomeLabel.useRegularFont()
        posetionAwayLabel.useRegularFont()
        passesHeaderLabel.useBoldFont()
        passesHomeLabel.useRegularFont()
        passesAwayLabel.useRegularFont()
        cornersHomeHeaderLabel.useBoldFont()
        cornerHomeLabel.useRegularFont()
        cornersAwayHeaderLabel.useBoldFont()
        cornerAwayLabel.useRegularFont()
        goalShotsHeaderLabel.useBoldFont()
        goalShotsHomeLabel.useRegularFont()
        goalShotsAwayLabel.useRegularFont()
        foulsHomeHeaderLabel.useBoldFont()
        faulsHomeLabel.useRegularFont()
        yellowCardsHomeLabel.useRegularFont()
        redCardsHomeLabel.useRegularFont()
        foulsAwayHeaderLabel.useBoldFont()
        faulsAwayLabel.useBoldFont()
        yellowCardsAwayLabel.useRegularFont()
        redCardsAwayLabel.useRegularFont()
        homeFormationLabel.useRegularFont()
        awayFormationLabel.useRegularFont()
        refereeHeaderLabel.useBoldFont()
        refereeLabel.useRegularFont()
        assistantsHeaderLabel.useBoldFont()
        assistant1Label.useRegularFont()
        assistant2Label.useRegularFont()
    }

    fileprivate func subscribe() {
        if matchID.isEmpty {
            guard let tempMatchID = matchStat?.matchInfo.id else {
                return
            }

            matchID = tempMatchID
        }

        matchStatsCardViewModel = MatchStatsCardViewModel(fixtureId: matchID)

        matchStatsCardViewModel.isLoading.asObservable()
            .subscribe(onNext: { isLoading in
                if isLoading {
                    // MBProgressHUD.showAdded(to: self.view, animated: true)
                } else {
                    // MBProgressHUD.hide(for: self.view, animated: true)
                }
            }, onError: { _ in
                // MBProgressHUD.hide(for: self.view, animated: true)
            }).disposed(by: bag)

        matchStatsCardViewModel.matchStatsCard.asObservable().subscribe(onNext: { [unowned self] _ in
            self.updateUI()

            if let model = self.matchStatsCardViewModel.matchStatsCard.value {
                self.updateHeartbeat(liveData: model.liveData, force: true)
                self.heartbeatBlock = { () -> Void in
                    self.matchStatsCardViewModel.fetch()
                }
            }
        }).disposed(by: bag)

        matchStatsCardViewModel.fetch()
    }

    fileprivate func updateUI() {
        if let model = matchStatsCardViewModel.matchStatsCard.value {
            goals = model.goals()

            playerFormationsView.homeTeamFormation = model.usedFormation(isHomeTeam: true)
            playerFormationsView.awayTeamFormation = model.usedFormation(isHomeTeam: false)

            homeFormationLabel.text = model.usedFormation(isHomeTeam: true, formatted: true)
            awayFormationLabel.text = model.usedFormation(isHomeTeam: false, formatted: true)

            let homePlayersAll = model.allPlayers(forHomeTeam: true)
            let awayPlayersAll = model.allPlayers(forHomeTeam: false)

            homePlayers = homePlayersAll.filter { $0.position != "Substitute" }
            awayPlayers = awayPlayersAll.filter { $0.position != "Substitute" }

            homeSubstitutes = homePlayersAll.filter { $0.position == "Substitute" }
            awaySubstitutes = awayPlayersAll.filter { $0.position == "Substitute" }

            playerFormationsView.homePlayers = model.sortedPlayers(forHomeTeam: true)
            playerFormationsView.awayPlayers = model.sortedPlayers(forHomeTeam: false)

            playerFormationsView.update()

            if let stat = model.stat(of: "possessionPercentage", isHomeTeam: true), let value = Float(stat.value ?? "") {
                posetionHomeLabel.text = "\(Int(value))%"
                posetionHomeProgressView.progress = value / 100.0
            }

            if let stat = model.stat(of: "possessionPercentage", isHomeTeam: false), let value = Float(stat.value ?? "") {
                posetionAwayLabel.text = "\(Int(value))%"
                posetionAwayProgressView.progress = value / 100.0
            }

            let pctPassesHome = model.calculatePercentBetweenStat(statType1: "accuratePass", statType2: "totalPass", isHomeTeam: true)
            let pctPassesAway = model.calculatePercentBetweenStat(statType1: "accuratePass", statType2: "totalPass", isHomeTeam: false)

            passesHomeLabel.text = "\(Int(pctPassesHome))%"
            passesHomeProgressView.progress = pctPassesHome / 100.0

            passesAwayLabel.text = "\(Int(pctPassesAway))%"
            passesAwayProgressView.progress = pctPassesAway / 100.0

            if let stat = model.stat(of: "cornerTaken", isHomeTeam: true) {
                cornerHomeLabel.text = stat.value
            }

            if let stat = model.stat(of: "cornerTaken", isHomeTeam: false) {
                cornerAwayLabel.text = stat.value
            }

            let pctGoalShotsHome = model.calculatePercentBetweenStat(statType1: "shotOffTarget", statType2: "totalScoringAtt", isHomeTeam: true)
            let pctGoalShotsAway = model.calculatePercentBetweenStat(statType1: "shotOffTarget", statType2: "totalScoringAtt", isHomeTeam: false)

            goalShotsHomeLabel.text = "\(Int(pctGoalShotsHome))%"
            goalShotsHomeProgressView.progress = pctGoalShotsHome / 100.0

            goalShotsAwayLabel.text = "\(Int(pctGoalShotsAway))%"
            goalShotsAwayProgressView.progress = pctGoalShotsAway / 100.0

            if let stat = model.stat(of: "totalTackle", isHomeTeam: true) {
                faulsHomeLabel.text = stat.value
            }

            if let stat = model.stat(of: "totalYellowCard", isHomeTeam: true) {
                yellowCardsHomeLabel.text = stat.value
            }

            if let stat = model.stat(of: "totalRedCard", isHomeTeam: true) {
                redCardsHomeLabel.text = stat.value
            }

            if let stat = model.stat(of: "totalTackle", isHomeTeam: false) {
                faulsAwayLabel.text = stat.value
            }

            if let stat = model.stat(of: "totalYellowCard", isHomeTeam: false) {
                yellowCardsAwayLabel.text = stat.value
            }

            if let stat = model.stat(of: "totalRedCard", isHomeTeam: false) {
                redCardsAwayLabel.text = stat.value
            }

            if let mainOfficial = model.matchOfficialsWithType(type: "Main").first {
                refereeLabel.text = mainOfficial
            }

            if let assistant1 = model.matchOfficialsWithType(type: "Lineman 1").first {
                assistant1Label.text = assistant1
            }

            if let assistant2 = model.matchOfficialsWithType(type: "Lineman 2").first {
                assistant2Label.text = assistant2
            }

            matchView.matchStat = model
        }

        goalsTableView.reloadData()
        goalsTableViewHeightConstraint.constant = goalsTableView.contentSize.height

        playerLineupTableView.reloadData()
        playerLineupTableViewHeightConstraint.constant = playerLineupTableView.contentSize.height

        matchView.didTapOnTeamFlag = { (_ teamID: String) -> Void in
            self.showTeamScreen(teamID: teamID)
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        goalsTableViewHeightConstraint.constant = goalsTableView.contentSize.height
        playerLineupTableViewHeightConstraint.constant = playerLineupTableView.contentSize.height
    }

    fileprivate func processMatchStats(matchID: String) {
        let matchStatsCardViewModel = MatchStatsCardViewModel(fixtureId: matchID)

        matchStatsCardViewModel.matchStatsCard.asObservable().subscribe { e in
            switch e {
            case .next:
                if let statCard = matchStatsCardViewModel.matchStatsCard.value {
                    self.matchStat = statCard
                }
            case let .error(error):
                print("Error: \(error)")
            case .completed:
                break
            }
        }.disposed(by: bag)

        matchStatsCardViewModel.fetch()
    }

    // MARK: -

    fileprivate func showPlayerDetails(id: String) {
        if id.isEmpty { return }

        let vc = mainStoryboard.instantiateViewController(withIdentifier: PlayerDetailsViewController.storyboardID) as! PlayerDetailsViewController
        vc.personID = id
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: -

    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == playerLineupTableView {
            return 3
        }

        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var result = 0

        if tableView == goalsTableView {
            result = goals.count
        }
        if tableView == playerLineupTableView {
            switch section {
            case 0:
                result = max(homePlayers.count, awayPlayers.count)
            case 1:
                result = max(homeSubstitutes.count, awaySubstitutes.count)
            case 2:
                result = 1
            default:
                break
            }
        }

        return result
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!

        if tableView == goalsTableView {
            let goal = goals[indexPath.row]

            if let model = matchStatsCardViewModel.matchStatsCard.value, model.isPlayerInHomeTeam(id: goal.scorerId ?? "") {
                cell = tableView.dequeueReusableCell(withIdentifier: "HomeGoalsCell")!
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "AwayGoalsCell")!
            }

            if let label = cell.viewWithTag(100) as? UILabel {
                label.text = "\(goal.timeMin ?? 0)"
            }

            if let label = cell.viewWithTag(300) as? UILabel {
                label.text = goal.scorerName?.uppercased() ?? ""
            }

            if let imageView = cell.viewWithTag(10) as? UIImageView {
                imageView.image = nil
                let renderer = UIGraphicsImageRenderer(bounds: imageView.bounds)
                imageView.image = renderer.image(actions: { (_ ctx: UIGraphicsImageRendererContext) in
                    ctx.cgContext.setStrokeColor(UIColor(white: 0.6, alpha: 1.0).cgColor)
                    ctx.cgContext.setLineDash(phase: 2.0, lengths: [4.0])
                    ctx.cgContext.stroke(imageView.bounds)
                })
            }
        } else if tableView == playerLineupTableView {
            let lineupCell = tableView.dequeueReusableCell(withIdentifier: "LineupTableViewCell") as! LineupTableViewCell

            if indexPath.section == 2 {
                lineupCell.homePlayer = nil
                lineupCell.awayPlayer = nil

                if let model = matchStatsCardViewModel.matchStatsCard.value {
                    if let lineup = model.lineUp(isHomeTeam: true) {
                        var name = lineup.teamOfficial?.firstName ?? ""
                        if !name.isEmpty, let lastname = lineup.teamOfficial?.lastName {
                            name += " \(lastname)"
                        }
                        lineupCell.homePlayerNameLabel.text = name
                    }
                    if let lineup = model.lineUp(isHomeTeam: false) {
                        var name = lineup.teamOfficial?.firstName ?? ""
                        if !name.isEmpty, let lastname = lineup.teamOfficial?.lastName {
                            name += " \(lastname)"
                        }
                        lineupCell.awayPlayerNameLabel.text = name
                    }
                } else {
                    lineupCell.homePlayerNameLabel.text = ""
                    lineupCell.awayPlayerNameLabel.text = ""
                }

            } else {
                let homePlayerList = indexPath.section == 0 ? homePlayers : homeSubstitutes
                let awayPlayerList = indexPath.section == 0 ? awayPlayers : awaySubstitutes

                if indexPath.row < homePlayerList.count {
                    lineupCell.homePlayer = LineupTableViewCellPlayer(player: homePlayerList[indexPath.row])
                }
                if indexPath.row < awayPlayerList.count {
                    lineupCell.awayPlayer = LineupTableViewCellPlayer(player: awayPlayerList[indexPath.row])
                }

                lineupCell.didSelectHomePlayer = { (_ cell) -> Void in
                    if let id = cell.homePlayer?.identifier {
                        self.showPlayerDetails(id: id)
                    }
                }

                lineupCell.didSelectAwayPlayer = { (_ cell) -> Void in
                    if let id = cell.awayPlayer?.identifier {
                        self.showPlayerDetails(id: id)
                    }
                }
            }

            cell = lineupCell
        }

        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return tableView == goalsTableView ? indexPath : nil
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if tableView == goalsTableView {
            let goal = goals[indexPath.row]

            if let id = goal.scorerId {
                showPlayerDetails(id: id)
            }
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == playerLineupTableView {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30.0))
            headerView.backgroundColor = .white

            let label = UILabel(frame: .zero)
            label.textAlignment = .center
            label.textColor = UIColor(white: 0.3, alpha: 1.0)
            label.font = UIFont.boldSystemFont(ofSize: 16.0)

            var text = ""

            switch section {
            case 0:
                text = Localized.getLocalizedString(from: "INITIAL TEAM")
            case 1:
                text = Localized.getLocalizedString(from: "RESERVES")
            case 2:
                text = Localized.getLocalizedString(from: "COACH")
            default:
                break
            }

            label.text = text
            label.useBoldFont()
            label.translatesAutoresizingMaskIntoConstraints = false

            headerView.addSubview(label)

            headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[label]-0-|", options: [], metrics: nil, views: ["label": label]))
            headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-2-[label]-2-|", options: [], metrics: nil, views: ["label": label]))

            return headerView
        }

        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView == playerLineupTableView ? 30.0 : 0.0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var result = UITableView.automaticDimension

        if tableView == goalsTableView {
            result = 32.0
        }
        if tableView == playerLineupTableView {
            result = 50.0
        }

        return result
    }
}
