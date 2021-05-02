//
//  PlayerDetailsViewController.swift
//  CopaAmericaStatsScreenPlugin
//
//  Created by Jesus De Meyer on 4/3/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import MBProgressHUD
import RxSwift
import UIKit

class PlayerDetailsViewController: ViewControllerBase {
    static var storyboardID: String = "PlayerDetailsViewController"

    var personID = ""
    var playerID = ""

    @IBOutlet var containerView: UIView!
    @IBOutlet var playerTypeLabel: UILabel!
    @IBOutlet var playerRealNameLabel: UILabel!
    @IBOutlet var playerFlagImageView: UIImageView!
    @IBOutlet var playerPhotoImageView: UIImageView!
    @IBOutlet var playerShieldImageView: UIImageView!

    @IBOutlet var playerDetailPosition: UILabel!
    @IBOutlet var playerDetailRole: UILabel!

    @IBOutlet var playerPositionHeader: UILabel!
    @IBOutlet var playerNumberHeader: UILabel!
    @IBOutlet var playerGoalsHeader: UILabel!
    @IBOutlet var playerTournamentsHeader: UILabel!
    @IBOutlet var playerBirthPlaceHeader: UILabel!
    @IBOutlet var playerDOBHeader: UILabel!
    @IBOutlet var playerClubHeader: UILabel!
    @IBOutlet var playerBiometryHeader: UILabel!
    @IBOutlet var playerHeightHeader: UILabel!
    @IBOutlet var playerWeightHeader: UILabel!
    @IBOutlet var playerNameHeader: UILabel!

    @IBOutlet var playerDetailPlaceOfBirth: UILabel!
    @IBOutlet var playerDetailDateOfBirth: UILabel!
    @IBOutlet var playerDetailProfessionalTeam: UILabel!
    @IBOutlet var playerDetailAmericaCups: UILabel!
    @IBOutlet var playerDetailGoals: UILabel!
    @IBOutlet var playerDetailHeight: UILabel!
    @IBOutlet var playerDetailWeight: UILabel!

    fileprivate var squadCareerCardViewModel: SquadCareerCardViewModel!
    fileprivate let bag = DisposeBag()

    fileprivate lazy var dateOfBirthDateFormatter: DateFormatter = {
        return DateFormatter.create(with: "dd/MM/yyyy", locale: Localized.locale)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        subscribe()

        containerView.layer.cornerRadius = 9.0
        containerView.layer.shadowRadius = 20.0
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        containerView.layer.shadowColor = UIColor.black.cgColor
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    fileprivate func subscribe() {
        if personID.isEmpty {
            return
        }

        squadCareerCardViewModel = SquadCareerCardViewModel(personId: personID)

        squadCareerCardViewModel.isLoading.asObservable()
            .subscribe(onNext: { [unowned self] isLoading in
                if isLoading {
                    MBProgressHUD.showAdded(to: self.view, animated: true)
                } else {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
            }, onError: { [unowned self] _ in
                MBProgressHUD.hide(for: self.view, animated: true)
            }).disposed(by: bag)

        squadCareerCardViewModel.squadCareerCard.asObservable().subscribe(onNext: { [unowned self] _ in
            if let squadCard = self.squadCareerCardViewModel.squadCareerCard.value {
                self.populate(squadCareerCard: squadCard)
            }
        }).disposed(by: bag)

        squadCareerCardViewModel.fetch()
    }

    fileprivate func setupUI() {
        playerTypeLabel.useRegularFont()
        playerNameHeader.useBoldFont()
        playerRealNameLabel.useBoldFont()

        playerPositionHeader.useBoldFont()
        playerDetailRole.useRegularFont()
        playerDetailPosition.useRegularFont()
        playerNumberHeader.useBoldFont()
        playerGoalsHeader.useBoldFont()
        playerDetailGoals.useRegularFont()
        playerTournamentsHeader.useBoldFont()
        playerDetailAmericaCups.useRegularFont()

        playerBirthPlaceHeader.useBoldFont()
        playerDetailPlaceOfBirth.useRegularFont()
        playerDOBHeader.useBoldFont()
        playerDetailDateOfBirth.useRegularFont()
        playerClubHeader.useBoldFont()
        playerDetailProfessionalTeam.useRegularFont()
        playerBiometryHeader.useBoldFont()

        playerHeightHeader.useBoldFont()
        playerDetailHeight.useRegularFont()
        playerWeightHeader.useBoldFont()
        playerDetailWeight.useRegularFont()

        playerTypeLabel.text = Localized.playerName[Localized.languageCode] as? String ?? "TIPO"
        playerPositionHeader.text = Localized.playerPositionHeader[Localized.languageCode] as? String ?? "POSICIÓN"
        playerGoalsHeader.text = Localized.goalsHeader[Localized.languageCode] as? String ?? "GOLES"
        playerTournamentsHeader.text = Localized.playerTournamentsHeader[Localized.languageCode] as? String ?? "TORNEOS"
        playerBirthPlaceHeader.text = Localized.playerPOBHeader[Localized.languageCode] as? String ?? "LUGAR DE NACIMIENTO"
        playerDOBHeader.text = Localized.playerDOBHeader[Localized.languageCode] as? String ?? "FECHA DE NACIMIENTO"
        playerClubHeader.text = Localized.playerProfessionalTeamHeader[Localized.languageCode] as? String ?? "EQUIPO PROFESIONAL"
        playerBiometryHeader.text = Localized.playerBiometryHeader[Localized.languageCode] as? String ?? "BIOMETRÍA"
        playerHeightHeader.text = Localized.playerHeightHeader[Localized.languageCode] as? String ?? "ALTURA"
        playerWeightHeader.text = Localized.playerWeightHeader[Localized.languageCode] as? String ?? "PESO"
    }

    fileprivate func getPlayerTeamId(player: SquadPerson?) -> String {
        guard let memberships = player?.memberships else { return "" }
        for membership in memberships {
            let membershipType = membership.contestantType ?? "noMembership"
            let active = membership.active ?? "no"

            if (membershipType == "national") && (active == "true" || active == "yes") {
                return membership.contestantId ?? ""
            }
        }
        return ""
    }

    fileprivate func populate(squadCareerCard: SquadCareerCard) {
        let person = squadCareerCard.person
        let teamId = getPlayerTeamId(player: person)

        let fallbackStringPlayerType = Localized.playerNameHeader[Localized.languageCode] as? String ?? ""
        playerTypeLabel.text = fallbackStringPlayerType
        // playerTypeLabel.text =  Localized.getLocalizedString(from: person?.type?.uppercased() ?? fallbackStringPlayerType) //person?.type?.uppercased() ?? fallbackStringPlayerType
        playerFlagImageView.image = nil
        
        let flagImageUrl = "\(OptaStats.pluginParams.imageBaseUrl)flag-\(teamId).png"
        playerFlagImageView.sd_setImage(with: URL(string: flagImageUrl), placeholderImage: nil)

        let shieldImageUrl = "\(OptaStats.pluginParams.imageBaseUrl)SHIELD-\(teamId).png"
        playerShieldImageView.sd_setImage(with: URL(string: shieldImageUrl), placeholderImage: nil)

        let imageBaseUrl = OptaStats.pluginParams.imageBaseUrl
        playerPhotoImageView.sd_setImage(with: URL(string: "\(imageBaseUrl)\(personID).png"), placeholderImage: nil)

        playerRealNameLabel.text = person?.matchName?.uppercased()

        playerDetailPosition.text = "N/A"
        if let player = person {
            playerDetailPosition.text = findPlayerShirtNumber(player: player)
        }

        let position = Localized.getLocalizedString(from: person?.position?.capitalized ?? "N/A")
        playerDetailRole.text = position.uppercased()

        if let date = person?.dateOfBirth {
            playerDetailDateOfBirth.text = dateOfBirthDateFormatter.string(from: date)
        } else {
            playerDetailDateOfBirth.text = "N/A"
        }
        var placeOfBirth = "N/A"

        if let value = person?.placeOfBirth {
            placeOfBirth = value.capitalized
            if let country = person?.countryOfBirth {
                placeOfBirth += ", \(country.uppercased())"
            }
        }

        playerDetailPlaceOfBirth.text = placeOfBirth
        playerDetailProfessionalTeam.text = "N/A"

        let filteredMemberships = person?.memberships?.filter { $0.contestantType?.lowercased() == "club" && $0.active == "yes" }

        if let membership = filteredMemberships?.first {
            playerDetailProfessionalTeam.text = membership.contestantName?.capitalized
        }

        playerDetailAmericaCups.text = "N/A"
        playerDetailGoals.text = "N/A"

        playerDetailWeight.text = "N/A"
        if let value = person?.weight {
            playerDetailWeight.text = "\(value) Kg."
        }

        playerDetailHeight.text = "N/A"
        if let value = person?.height {
            playerDetailHeight.text = "\(value) cm."
        }

        if let player = person {
            let stats = getCupsFromPlayer(player: player)

            playerDetailAmericaCups.text = "\(stats.count)"
            playerDetailGoals.text = "\(findPlayerGoals(player: player))"
        }
    }

    fileprivate func getCupsFromPlayer(player: SquadPerson) -> [SquadStat] {
        var result = [SquadStat]()

        if let memberships = player.memberships {
            for membership in memberships {
                if let stats = membership.stats {
                    for stat in stats {
                        if stat.competitionName?.lowercased() == "copa america" {
                            result.append(stat)
                        }
                    }
                }
            }
        }

        return result
    }

    fileprivate func findPlayerShirtNumber(player: SquadPerson) -> String {
        var result = "N/A"

        guard let memberships = player.memberships else {
            return result
        }

        for membership in memberships {
            guard let stats = membership.stats else {
                continue
            }

            for stat in stats {
                if stat.competitionId == OptaStats.pluginParams.competitionId &&
                    stat.tournamentCalendarId == OptaStats.pluginParams.calendarId {
                    if let number = stat.shirtNumber {
                        result = "\(number)"
                        return result
                    }
                }
            }
        }

        return result
    }

    fileprivate func findPlayerGoals(player: SquadPerson) -> Int {
        var result = 0

        guard let memberships = player.memberships else {
            return result
        }

        for membership in memberships {
            guard let stats = membership.stats else {
                continue
            }

            for stat in stats {
                if stat.competitionId == OptaStats.pluginParams.competitionId &&
                    stat.tournamentCalendarId == OptaStats.pluginParams.calendarId {
                    if let number = stat.goals {
                        result += number
                    }
                }
            }
        }

        return result
    }

    @objc func dismissPlayerDetailsVC() {
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
