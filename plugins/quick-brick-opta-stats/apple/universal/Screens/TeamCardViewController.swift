//
//  TeamCardViewController.swift
//  CopaAmericaStatsScreenPlugin
//
//  Created by Marcos Reyes - Applicaster on 3/8/19.
//

import Foundation
import MBProgressHUD
import RxCocoa
import RxSwift

class TeamCardViewController: ViewControllerBase {
    static let storyboardID = "TeamCardViewController"

    var teamID = ""
    var squadMembers: [SquadPerson] = [SquadPerson]()

    var controllerPresentedfModally: Bool = true

    @IBOutlet var tableView: UITableView!
    @IBOutlet var noInformationToDisplayView: UIView!
    @IBOutlet var noInformationLabel: UILabel!

    fileprivate var squadCardViewModel: SquadCardViewModel!
    fileprivate var teamCardViewModel: TeamCardViewModel!

    let statsToDisplay: [String] = ["Total Shots", "Possession Percentage", "Goals", "Duels won"]
    let bag = DisposeBag()

    enum TeamCardSection: Int, CaseIterable {
        case teamStats = 0
        case upcomingMatches = 1
        case players = 2
    }

    fileprivate var noDataMessageVisible: Bool = false {
        didSet {
            if noDataMessageVisible {
                tableView.isHidden = true
                noInformationToDisplayView.isHidden = false
            } else {
                tableView.isHidden = false
                noInformationToDisplayView.isHidden = true
            }
            setTableViewHeader()
        }
    }

    fileprivate var nextMatchesTableViewCell: TeamNextMatchesTableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()

        styleUI()
        subscribe()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 130
        tableView.register(UINib(nibName: "TeamCardTableHeaderView", bundle: Bundle(for: classForCoder)), forCellReuseIdentifier: "TeamCardTableHeaderView")
        tableView.register(UINib(nibName: "TeamNextMatchesTableViewCell", bundle: Bundle(for: classForCoder)), forCellReuseIdentifier: "TeamNextMatchesTableViewCell")
        tableView.register(UINib(nibName: "TeamCardPlayerTableViewCell", bundle: Bundle(for: classForCoder)), forCellReuseIdentifier: "TeamCardPlayerTableViewCell")
        tableView.register(UINib(nibName: "TeamCardPlayerTableViewCellAlt", bundle: Bundle(for: classForCoder)), forCellReuseIdentifier: "TeamCardPlayerTableViewCellAlt")
        tableView.register(UINib(nibName: "EmptySpacerTableViewCell", bundle: Bundle(for: classForCoder)), forCellReuseIdentifier: "EmptySpacerTableViewCell")
        tableView.isHidden = true

        NotificationCenter.default.addObserver(self, selector: #selector(handleDeviceOrientation(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.layoutSubviews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableView.layoutSubviews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        print("Deinitializing TeamCardViewController")
    }

    @objc
    func handleDeviceOrientation(_ sender: Notification) {
        tableView.tableHeaderView?.frame.size = CGSize(width: tableView.frame.width, height: CGFloat(418.0))
        tableView.tableHeaderView?.layoutSubviews()
        tableView.layoutSubviews()
    }

    private func styleUI() {
        tableView.backgroundColor = .clear
        tableView.contentInset = UIEdgeInsets(top: 34, left: 0, bottom: 0, right: 0)
        tableView.clipsToBounds = false
        tableView.layer.masksToBounds = false

        tableView.layer.shadowColor = UIColor.darkGray.cgColor
        tableView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        tableView.layer.shadowOpacity = 0.1
        tableView.layer.shadowRadius = 20.0

        noInformationLabel.useBoldFont()
        noInformationLabel.text = Localized.informationNotAvailable[Localized.languageCode] as? String ?? "Esta información no está disponible todavía"
        if let helveticaFont = UIFont(name: "HelveticaNeue-CondensedBold", size: 20) {
            noInformationLabel.font = helveticaFont
        }
        noInformationToDisplayView.isHidden = true
        noInformationToDisplayView.layer.cornerRadius = 16.0
        noInformationToDisplayView.layer.shadowColor = UIColor.darkGray.cgColor
        noInformationToDisplayView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        noInformationToDisplayView.layer.shadowOpacity = 0.4
        noInformationToDisplayView.layer.shadowRadius = 4.0

        noInformationToDisplayView.isHidden = true
        tableView.isHidden = true
    }

    private func setTableViewHeader() {
        let view = (Bundle(for: classForCoder).loadNibNamed("TeamCardTableHeaderView", owner: self, options: nil)?[0] as? TeamCardTableHeaderView)
        tableView.tableHeaderView = view
        if squadCardViewModel != nil {
            view?.squadCard = squadCardViewModel.squadCard.value
        }
        if teamCardViewModel != nil {
            view?.teamCard = teamCardViewModel.teamCard.value
            view?.numberOfTrophies = teamCardViewModel.numberOfTrophies.value
        }

        tableView.tableHeaderView?.frame.size = CGSize(width: tableView.frame.width, height: CGFloat(418.0))
    }

    private func subscribe() {
        squadCardViewModel = SquadCardViewModel(contestantId: teamID)
        teamCardViewModel = TeamCardViewModel(contestantId: teamID)

        squadCardViewModel?.isLoading.asObservable()
            .subscribe(onNext: { [unowned self] isLoading in
                if isLoading {
                    MBProgressHUD.showAdded(to: self.view, animated: true)
                } else {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
            }, onError: { [unowned self] _ in
                MBProgressHUD.hide(for: self.view, animated: true)
            }).disposed(by: bag)

        squadCardViewModel?.squadCard.asObservable()
            .subscribe(onNext: { [unowned self] _ in
                if let model = self.squadCardViewModel.squadCard.value, let persons = model.squad?.persons {
                    self.noDataMessageVisible = persons.count == 0
                }

                if let _ = self.squadCardViewModel.squadCard.value {
                    self.updateHeartbeat(liveData: nil, force: true)
                    self.heartbeatBlock = { () -> Void in
                        self.teamCardViewModel.fetch()
                    }
                }

                self.teamCardViewModel.fetch()
                self.tableView.reloadData()
            }).disposed(by: bag)

        teamCardViewModel?.isLoading.asObservable()
            .subscribe(onNext: { [unowned self] isLoading in
                if isLoading {
                    MBProgressHUD.showAdded(to: self.view, animated: true)
                } else {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
            }, onError: { [unowned self] _ in
                MBProgressHUD.hide(for: self.view, animated: true)
            }).disposed(by: bag)

        teamCardViewModel?.teamCard.asObservable()
            .subscribe(onNext: { [unowned self] _ in
                var count = 0

                if let model = self.squadCardViewModel.squadCard.value, let persons = model.squad?.persons {
                    count += persons.count
                }

                if let model = self.teamCardViewModel.teamCard.value, let players = model.players {
                    count += players.count
                }

                if self.noDataMessageVisible == (count == 0) {
                    self.noDataMessageVisible = count == 0
                }

                self.setSortedSquadMembers()
                self.teamCardViewModel.fetchTournamentWinners(contestantId: self.teamID)
                self.tableView.reloadData()
            }).disposed(by: bag)

        teamCardViewModel?.numberOfTrophies.asObservable()
            .subscribe(onNext: { [unowned self] _ in
                self.setTableViewHeader()
                self.tableView.reloadData()
            }).disposed(by: bag)

        teamCardViewModel?.errorOnFetch.asObservable()
            .subscribe(onNext: { errorOnFetch in
                if errorOnFetch {
                    // self.noDataMessageVisible = true
                }
            }).disposed(by: bag)

        squadCardViewModel.fetch()
    }

    private func setSortedSquadMembers() {
        guard let squadMembersList = squadCardViewModel.squadCard.value?.squad?.persons, squadMembersList.count > 0 else { return }

        let goalkeepers = squadMembersList.filter { (squadPerson) -> Bool in
            guard let type = squadPerson.type, type.uppercased() == "PLAYER" else { return false }
            if let position = squadPerson.position {
                if position.uppercased() == "GOALKEEPER" {
                    return true
                }
            }
            return false
        }

        let defenders = squadMembersList.filter { (squadPerson) -> Bool in
            guard let type = squadPerson.type, type.uppercased() == "PLAYER" else { return false }
            if let position = squadPerson.position {
                if position.uppercased() == "DEFENDER" {
                    return true
                }
            }
            return false
        }

        let midfielders = squadMembersList.filter { (squadPerson) -> Bool in
            guard let type = squadPerson.type, type.uppercased() == "PLAYER" else { return false }
            if let position = squadPerson.position {
                if position.uppercased() == "MIDFIELDER" {
                    return true
                }
            }
            return false
        }

        let strikers = squadMembersList.filter { (squadPerson) -> Bool in
            guard let type = squadPerson.type, type.uppercased() == "PLAYER" else { return false }
            if let position = squadPerson.position {
                if (position.uppercased() == "ATTACKER") || (position.uppercased() == "STRIKER") {
                    return true
                }
            }
            return false
        }

        let unknowns = squadMembersList.filter { (squadPerson) -> Bool in
            guard let type = squadPerson.type, type.uppercased() == "PLAYER" else { return false }
            if let position = squadPerson.position {
                if position.uppercased() == "UNKNOWN" {
                    return true
                }
            }
            return false
        }

        let coaches = squadMembersList.filter { (squadPerson) -> Bool in
            guard let type = squadPerson.type, type.uppercased() == "COACH" else { return false }
            return true
        }

        let assistantCoaches = squadMembersList.filter { (squadPerson) -> Bool in
            guard let type = squadPerson.type, type.uppercased() == "ASSISTANT COACH" else { return false }
            return true
        }

        let coaching = assistantCoaches + coaches
        squadMembers = goalkeepers
        squadMembers += defenders
        squadMembers += midfielders
        squadMembers += strikers
        squadMembers += unknowns
        squadMembers += coaching
    }

    @objc func dismissTeamCardVC() {
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
}

extension TeamCardViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return TeamCardSection.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case TeamCardSection.players.rawValue:
            var count = 0

            if OptaStats.pluginParams.showTeam {
                if let list = squadCardViewModel.squadCard.value?.squad?.persons {
                    count = list.count
                } else if let list = teamCardViewModel.teamCard.value?.players {
                    count = list.count
                }

                count += 2
            }

            return count
        case TeamCardSection.upcomingMatches.rawValue:
            return 1
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case TeamCardSection.players.rawValue:
            var itemsCount = 0

            if let list = squadCardViewModel.squadCard.value?.squad?.persons {
                squadMembers = list
                itemsCount = list.count
            } else if let list = teamCardViewModel.teamCard.value?.players {
                itemsCount = list.count
            }

            if indexPath.row == 0 || indexPath.row == itemsCount + 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "EmptySpacerTableViewCell", for: indexPath) as! EmptySpacerTableViewCell
                cell.selectionStyle = .none
                cell.isTop = indexPath.row == 0
                if indexPath.row == 0 {
                    cell.customLabel.font = UIFont.boldSystemFont(ofSize: 15.0)
                    cell.customText = Localized.getLocalizedString(from: "INITIAL TEAM")
                } else {
                    cell.customText = ""
                }
                return cell
            } else {
                var cell = UITableViewCell()
                let index = indexPath.row - 1

                let identifier = index % 2 == 0 ? "TeamCardPlayerTableViewCell" : "TeamCardPlayerTableViewCellAlt"
                cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! TeamCardPlayerTableViewCell

                if let cell = cell as? TeamCardPlayerTableViewCell {
                    if index < squadMembers.count {
                        cell.person = squadMembers[index]
                    } else if let list = teamCardViewModel.teamCard.value?.players, index < list.count {
                        cell.player = list[index]
                    }
                }

                cell.selectionStyle = .none
                cell.layoutIfNeeded()
                cell.selectionStyle = .none

                return cell
            }
        case TeamCardSection.upcomingMatches.rawValue:
            if nextMatchesTableViewCell == nil {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TeamNextMatchesTableViewCell", for: indexPath) as! TeamNextMatchesTableViewCell
                cell.teamID = teamID
                cell.update()
                cell.collectionView.launchMatchScreenBlock = { (_ matchStat: MatchStatsCard) -> Void in
                    self.showMatchDetailScreenWithStat(matchStat: matchStat)
                }
                cell.collectionView.launchTeamScreenBlock = { (_ teamID: String) -> Void in
                    if teamID != self.teamID {
                        self.showTeamScreen(teamID: teamID)
                    }
                }

                nextMatchesTableViewCell = cell
            }

            return nextMatchesTableViewCell
        default:
            return UITableViewCell()
        }
    }
}

extension TeamCardViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        var count = 0

        if let list = squadCardViewModel.squadCard.value?.squad?.persons {
            count = list.count
        } else if let list = teamCardViewModel.teamCard.value?.players {
            count = list.count
        }

        if indexPath.row == 0 || indexPath.row > count {
            return nil
        }

        return indexPath
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != TeamCardSection.players.rawValue { return }

        let index = indexPath.row - 1

        guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: PlayerDetailsViewController.storyboardID) as? PlayerDetailsViewController else {
            return
        }

        if index < squadMembers.count {
            let person = squadMembers[index]

            // if user selected a Coach or Assistant Coach, don't show Player Details view
            if let type = person.type, type.uppercased() == "COACH" { return }
            if let type = person.type, type.uppercased() == "ASSISTANT COACH" { return }
            viewController.personID = person.id ?? ""
        }
        if let list = teamCardViewModel.teamCard.value?.players, index < list.count {
            let player = list[index]
            viewController.playerID = player.id ?? ""
        }

        navigationController?.pushViewController(viewController, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case TeamCardSection.upcomingMatches.rawValue:
            return 252.0
        default:
            var count = 0

            if let list = squadCardViewModel.squadCard.value?.squad?.persons {
                count = list.count
            } else if let list = teamCardViewModel.teamCard.value?.players {
                count = list.count
            }

            if indexPath.row == 0 || indexPath.row > count {
                return 50.0
            }

            return 100.0
        }
    }
}

extension TeamCardViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
}
