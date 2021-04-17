//
//  TeamCardTableHeaderUIView.swift
//  CopaAmericaStatsScreenPlugin
//
//  Created by Marcos Reyes - Applicaster on 3/8/19.
//

import Foundation
import SDWebImage
import UIKit

class TeamCardTableHeaderView: UIView {
    @IBOutlet var teamHeaderLabel: UILabel!
    @IBOutlet var teamNameLabel: UILabel!
    @IBOutlet var teamFlagImageView: UIImageView!
    @IBOutlet var teamShieldImageView: UIImageView!
    @IBOutlet var teamShirtImageView: UIImageView!
    @IBOutlet var statsHeaderLabel: UILabel!
    @IBOutlet var teamGoalsMadeHeaderLabel: UILabel!
    @IBOutlet var teamGoalsMadeLabel: UILabel!
    @IBOutlet var teamGoalsAgainstHeaderLabel: UILabel!
    @IBOutlet var teamGoalsAgainstLabel: UILabel!
    @IBOutlet var posessionHeaderLabel: UILabel!
    @IBOutlet var posessionLabel: UILabel!
    @IBOutlet var passAccuracyHeaderLabel: UILabel!
    @IBOutlet var passAccuracyLabel: UILabel!
    @IBOutlet var amountOfTrophiesLabel: UILabel!
    @IBOutlet var trophyImageView: UIImageView!

    var teamCard: TeamCard? {
        didSet {
            setTeamDetails()
        }
    }

    var squadCard: SquadCard? {
        didSet {
            setTeamDetails()
        }
    }

    var numberOfTrophies: Int? {
        didSet {
            setNumberOfTropies()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setupUI()
    }

    private func setupUI() {
        backgroundColor = UIColor.white

        teamHeaderLabel.useMediumBoldFont()
        teamNameLabel.useBoldFont()
        statsHeaderLabel.useBoldFont()
        amountOfTrophiesLabel.useMediumBoldFont()

        teamGoalsMadeHeaderLabel.useBoldFont()
        teamGoalsMadeLabel.useBoldFont()
        teamGoalsAgainstHeaderLabel.useBoldFont()
        teamGoalsAgainstLabel.useBoldFont()
        posessionHeaderLabel.useBoldFont()
        posessionLabel.useBoldFont()
        passAccuracyHeaderLabel.useBoldFont()
        passAccuracyLabel.useBoldFont()

        teamHeaderLabel.text = Localized.team[Localized.getLocalizedLanguageCode()] as? String ?? "EQUIPO"
        statsHeaderLabel.text = Localized.teamCardStatsHeader[Localized.getLocalizedLanguageCode()] as? String ?? "PROMEDIO POR PARTIDO"
        teamGoalsMadeHeaderLabel.text = Localized.teamGoalsMadeHeader[Localized.getLocalizedLanguageCode()] as? String ?? "GOLES A FAVOR"
        teamGoalsAgainstHeaderLabel.text = Localized.teamGoalsAgainstHeader[Localized.getLocalizedLanguageCode()] as? String ?? "GOLES EN CONTRA"
        posessionHeaderLabel.text = Localized.teamPosessionHeader[Localized.getLocalizedLanguageCode()] as? String ?? "POSESIÓN"
        passAccuracyHeaderLabel.text = Localized.teamPassAccuracyHeader[Localized.getLocalizedLanguageCode()] as? String ?? "EXACTITUD DE PASE"

        layer.cornerRadius = 15.0
    }

    private func setTeamDetails() {
        if let card = squadCard {
            setTeamDetailsWithSquad(card)
        }

        if let card = teamCard {
            setTeamDetailsWithTeam(card)
        }

        updateConstraints()
        layoutIfNeeded()
    }

    fileprivate func setTeamDetailsWithSquad(_ card: SquadCard) {
        guard let squad = card.squad else { return }

        if let teamName = squad.contestantName {
            teamNameLabel.text = teamName
        }

        if let path = Bundle(for: classForCoder).path(forResource: "flag-\(squad.contestantId ?? "")", ofType: "png") {
            teamFlagImageView.image = UIImage(contentsOfFile: path)
            teamFlagImageView.layer.cornerRadius = 4
            teamFlagImageView.clipsToBounds = true
            teamFlagImageView.layer.borderColor = UIColor.lightGray.cgColor
            teamFlagImageView.layer.borderWidth = 0.25
        } else {
            teamFlagImageView.image = nil
        }

        if let path = Bundle(for: classForCoder).path(forResource: "SHIRT-\(squad.contestantId ?? "")", ofType: "png") {
            teamShirtImageView.image = UIImage(contentsOfFile: path)
        } else {
            teamShirtImageView.image = nil
        }

        if let path = Bundle(for: classForCoder).path(forResource: "SHIELD-\(squad.contestantId ?? "")", ofType: "png") {
            teamShieldImageView.image = UIImage(contentsOfFile: path)
        } else {
            teamShieldImageView.image = nil
        }

        if let path = Bundle(for: classForCoder).path(forResource: "copa-icon", ofType: "png") {
            trophyImageView.image = UIImage(contentsOfFile: path)
        } else {
            trophyImageView.image = nil
        }
        trophyImageView.isHidden = true
        amountOfTrophiesLabel.isHidden = true

        teamGoalsMadeLabel.text = "-"
        teamGoalsAgainstLabel.text = "-"
        posessionLabel.text = "-"
        passAccuracyLabel.text = "-"
    }

    fileprivate func setTeamDetailsWithTeam(_ card: TeamCard) {
        guard let teamCard = self.teamCard else { return }

        if let teamName = teamCard.contestantStat?.name {
            teamNameLabel.text = teamName
        }

        if let path = Bundle(for: classForCoder).path(forResource: "flag-\(teamCard.contestantStat?.id ?? "")", ofType: "png") {
            teamFlagImageView.image = UIImage(contentsOfFile: path)
        } else {
            teamFlagImageView.image = nil
        }

        if let path = Bundle(for: classForCoder).path(forResource: "SHIRT-\(teamCard.contestantStat?.id ?? "")", ofType: "png") {
            teamShirtImageView.image = UIImage(contentsOfFile: path)
        } else {
            teamShirtImageView.image = nil
        }

        if let path = Bundle(for: classForCoder).path(forResource: "SHIELD-\(teamCard.contestantStat?.id ?? "")", ofType: "png") {
            teamShieldImageView.image = UIImage(contentsOfFile: path)
        } else {
            teamShieldImageView.image = nil
        }

        if let path = Bundle(for: classForCoder).path(forResource: "copa-icon", ofType: "png") {
            trophyImageView.image = UIImage(contentsOfFile: path)
        } else {
            trophyImageView.image = nil
        }
        trophyImageView.isHidden = true
        amountOfTrophiesLabel.isHidden = true

        if let teamStats = teamCard.contestantStat?.stat {
            for stat in teamStats {
                let statName = stat.name ?? ""

                if statName == "Goals" {
                    let statValue = Int(stat.value ?? 0.0)
                    teamGoalsMadeLabel.text = "\(statValue)"
                }

                if statName == "Goals Conceded" {
                    let statValue = Int(stat.value ?? 0.0)
                    teamGoalsAgainstLabel.text = "\(statValue)"
                }

                if statName == "Possession Percentage" {
                    let statValue = Double(stat.value ?? 0.0)
                    posessionLabel.text = "\(statValue)%"
                }

                if statName == "Passing Accuracy" {
                    let statValue = Double(stat.value ?? 0.0)
                    passAccuracyLabel.text = "\(statValue)%"
                }
            }
        }
    }

    func setNumberOfTropies() {
        guard let numberOfTrophies = self.numberOfTrophies else {
            trophyImageView.isHidden = true
            amountOfTrophiesLabel.isHidden = true
            return
        }

        trophyImageView.isHidden = (numberOfTrophies == 0) ? true : false
        amountOfTrophiesLabel.isHidden = (numberOfTrophies == 0) ? true : false

        if numberOfTrophies > 0 {
            amountOfTrophiesLabel.text = "X \(numberOfTrophies)"
        }
    }

    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
