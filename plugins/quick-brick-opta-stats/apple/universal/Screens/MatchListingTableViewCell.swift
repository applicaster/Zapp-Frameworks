//
//  MatchListingTableViewCell.swift
//  CopaAmericaStatsScreenPlugin
//
//  Created by Jesus De Meyer on 4/1/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import RxSwift
import UIKit

class MatchListingTableViewCell: UITableViewCell {
    var match: MatchDetail? {
        didSet {
            updateUI()
        }
    }

    var didTapOnTeamFlag: ((String) -> Void)?
    var team1FlagImageRecognizer: UITapGestureRecognizer?
    var team2FlagImageRecognizer: UITapGestureRecognizer?

    @IBOutlet var cellBackgroundContainerView: UIView!
    @IBOutlet var homeFlagImageView: UIImageView!
    @IBOutlet var homeNameLabel: UILabel!

    @IBOutlet var awayFlagImageView: UIImageView!
    @IBOutlet var awayNameLabel: UILabel!

    @IBOutlet var matchTimeLabel: UILabel!
    @IBOutlet var matchGroupLabel: UILabel!
    @IBOutlet var matchVenueLabel: UILabel!

    @IBOutlet var homeScoreLabel: UILabel!
    @IBOutlet var awayScoreLabel: UILabel!
    @IBOutlet var halfLabel: UILabel!
    @IBOutlet var matchProgressView: UIProgressView!
    @IBOutlet var minuteInGameLabel: UILabel!

    @IBOutlet var penaltiesContainerView: UIView!
    @IBOutlet var penaltiesLabel: UILabel!
    @IBOutlet var homePenaltyScoreLabel: UILabel!
    @IBOutlet var awayPenaltyScoreLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        homeNameLabel.useRegularFont()
        awayNameLabel.useRegularFont()
        matchTimeLabel.useBoldFont()
        matchGroupLabel.useBoldFont()
        matchVenueLabel.useRegularFont()
        homeScoreLabel.useBoldFont()
        awayScoreLabel.useBoldFont()
        halfLabel.useBoldFont()
        minuteInGameLabel.useBoldFont()

        cellBackgroundContainerView.layer.cornerRadius = 9
        cellBackgroundContainerView.layer.shadowColor = UIColor.black.cgColor
        cellBackgroundContainerView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        cellBackgroundContainerView.layer.shadowOpacity = 0.1
        cellBackgroundContainerView.layer.shadowRadius = 20.0

        roundProgressView()
    }

    override func prepareForReuse() {
        didTapOnTeamFlag = nil
        if let team1FlagImageRecognizer = team1FlagImageRecognizer {
            homeFlagImageView.removeGestureRecognizer(team1FlagImageRecognizer)
        }
        if let team2FlagImageRecognizer = team2FlagImageRecognizer {
            awayFlagImageView.removeGestureRecognizer(team2FlagImageRecognizer)
        }
        if let path = Bundle(for: classForCoder).path(forResource: "flag-unknown", ofType: "png") {
            homeFlagImageView.image = UIImage(contentsOfFile: path)
        }
        if let path = Bundle(for: classForCoder).path(forResource: "flag-unknown", ofType: "png") {
            awayFlagImageView.image = UIImage(contentsOfFile: path)
        }

        roundProgressView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        roundProgressView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    fileprivate func updateUI() {
        homeNameLabel.text = "-"

        homeFlagImageView.image = nil
        if let path = Bundle(for: classForCoder).path(forResource: "flag-unknown", ofType: "png") {
            homeFlagImageView.image = UIImage(contentsOfFile: path)
        }
        homeFlagImageView.isUserInteractionEnabled = false

        awayNameLabel.text = "-"
        awayFlagImageView.image = nil
        if let path = Bundle(for: classForCoder).path(forResource: "flag-unknown", ofType: "png") {
            awayFlagImageView.image = UIImage(contentsOfFile: path)
        }
        awayFlagImageView.isUserInteractionEnabled = false

        matchTimeLabel.text = "-"

        matchGroupLabel.text = "-"
        matchVenueLabel.text = "-"

        guard let match = match else {
            return
        }

        if let contestants = match.contestants {
            for (index, contestant) in contestants.enumerated() {
                switch index {
                case 0:
                    homeNameLabel.text = contestant.code?.uppercased()

                    if let homeContestantId = contestant.id, let path = Bundle(for: classForCoder).path(forResource: "flag-\(homeContestantId)", ofType: "png") {
                        homeFlagImageView.image = UIImage(contentsOfFile: path)
                    } else if let path = Bundle(for: classForCoder).path(forResource: "flag-unknown", ofType: "png") {
                        homeFlagImageView.image = UIImage(contentsOfFile: path)
                    } else {
                        homeFlagImageView.image = nil
                    }
                    if let _ = didTapOnTeamFlag {
                        team1FlagImageRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnTeam1FlagAction))
                        if let team1FlagImageRecognizer = team1FlagImageRecognizer {
                            homeFlagImageView.isUserInteractionEnabled = true
                            homeFlagImageView.addGestureRecognizer(team1FlagImageRecognizer)
                        }
                    }
                case 1:
                    awayNameLabel.text = contestant.code?.uppercased()

                    if let awayContestantId = contestant.id, let path = Bundle(for: classForCoder).path(forResource: "flag-\(awayContestantId)", ofType: "png") {
                        awayFlagImageView.image = UIImage(contentsOfFile: path)
                    } else if let path = Bundle(for: classForCoder).path(forResource: "flag-unknown", ofType: "png") {
                        awayFlagImageView.image = UIImage(contentsOfFile: path)
                    } else {
                        awayFlagImageView.image = nil
                    }
                    if let _ = didTapOnTeamFlag {
                        team2FlagImageRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnTeam2FlagAction))
                        if let team2FlagImageRecognizer = team2FlagImageRecognizer {
                            awayFlagImageView.isUserInteractionEnabled = true
                            awayFlagImageView.addGestureRecognizer(team2FlagImageRecognizer)
                        }
                    }
                default:
                    break
                }
            }
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, dd MMMM - HH:mm"

        if let date = match.date {
            let text = dateFormatter.string(from: date)
            matchTimeLabel.text = "\(text)H".uppercased()
        }

        updateWithMatchDetail()
    }

    fileprivate func updateWithMatchDetail() {
        let seriesName = match?.series?.name ?? ""
        let stageName = match?.stage?.name?.uppercased() ?? ""

        if (stageName == "GROUP STAGE") || (stageName == "FASE DE GRUPOS") {
            matchGroupLabel.text = seriesName.uppercased()
        } else {
            matchGroupLabel.text = stageName
        }

        matchVenueLabel.text = match?.venue?.shortName?.uppercased() ?? ""

        homeScoreLabel.text = "-"
        awayScoreLabel.text = "-"

        if let details = match?.liveData?.matchDetails, details.matchStatus?.lowercased() != "fixture" {
            homeScoreLabel.text = "0"
            awayScoreLabel.text = "0"

            if let value = details.scores?.et?.home {
                homeScoreLabel.text = "\(value)"
            } else if let value = details.scores?.ft?.home {
                homeScoreLabel.text = "\(value)"
            } else if let value = details.scores?.ht?.home {
                homeScoreLabel.text = "\(value)"
            } else if let value = details.scores?.total?.home {
                homeScoreLabel.text = "\(value)"
            }
            if let value = details.scores?.et?.away {
                awayScoreLabel.text = "\(value)"
            } else if let value = details.scores?.ft?.away {
                awayScoreLabel.text = "\(value)"
            } else if let value = details.scores?.ht?.away {
                awayScoreLabel.text = "\(value)"
            } else if let value = details.scores?.total?.away {
                awayScoreLabel.text = "\(value)"
            }
        }

        if let matchStatus = match?.liveData?.matchDetails?.matchStatus {
            halfLabel.text = matchStatus.uppercased()
        }

        var matchStatusStr: String = ""
        if let matchStatus = match?.liveData?.matchDetails?.matchStatus {
            switch matchStatus.uppercased() {
            case "PLAYING", "PLAYED":
                matchStatusStr = matchStatus.uppercased()
                halfLabel.text = Localized.getLocalizedString(from: matchStatus.uppercased())
            default:
                halfLabel.text = " "
            }
        } else {
            halfLabel.text = " "
        }

        var gameTimeMinInt: Int = 0
        var halfTime: Bool = false
        if matchStatusStr == "PLAYING" {
            if let gameTimeMin = match?.liveData?.matchDetails?.matchTime {
                gameTimeMinInt = gameTimeMin
            } else if let periods = match?.liveData?.matchDetails?.periods, let firstPeriod = periods.first, let periodTime = firstPeriod.lengthMin, periodTime > 0 {
                halfTime = true
            }
        } else if matchStatusStr == "PLAYED" {
            if let gameTimeMin = match?.liveData?.matchDetails?.matchLengthMin {
                gameTimeMinInt = gameTimeMin
            }
        }

        if gameTimeMinInt > 0 {
            minuteInGameLabel.text = "\(gameTimeMinInt)'"

            let totalGameTimeInMins = 90
            let percent = (100.0 / Float(totalGameTimeInMins)) * Float(gameTimeMinInt)
            matchProgressView.progress = percent >= 100.0 ? 1.0 : percent / 100.0
        } else {
            if halfTime {
                minuteInGameLabel.text = Localized.getLocalizedString(from: "HALF")
                matchProgressView.progress = 0.5
            } else {
                minuteInGameLabel.text = ""
                matchProgressView.progress = 0.0
            }
        }

        if let _ = match?.liveData?.matchDetails?.scores?.pen {
            penaltiesContainerView.isHidden = false
            homePenaltyScoreLabel.isHidden = false
            awayPenaltyScoreLabel.isHidden = false

            if let value = match?.liveData?.matchDetails?.scores?.et?.home {
                homeScoreLabel.text = "\(value)"
            } else if let value = match?.liveData?.matchDetails?.scores?.ft?.home {
                homeScoreLabel.text = "\(value)"
            }
            if let value = match?.liveData?.matchDetails?.scores?.et?.away {
                awayScoreLabel.text = "\(value)"
            } else if let value = match?.liveData?.matchDetails?.scores?.ft?.away {
                awayScoreLabel.text = "\(value)"
            }
            if let value = match?.liveData?.matchDetails?.scores?.total?.home {
                homePenaltyScoreLabel.text = "\(value)"
            } else {
                homePenaltyScoreLabel.text = "-"
            }
            if let value = match?.liveData?.matchDetails?.scores?.total?.away {
                awayPenaltyScoreLabel.text = "\(value)"
            } else {
                awayPenaltyScoreLabel.text = "-"
            }
        } else {
            penaltiesContainerView.isHidden = true
            homePenaltyScoreLabel.text = "-"
            awayPenaltyScoreLabel.text = "-"
            homePenaltyScoreLabel.isHidden = true
            awayPenaltyScoreLabel.isHidden = true
        }
    }

    private func roundProgressView() {
        matchProgressView.layer.cornerRadius = 4
        matchProgressView.clipsToBounds = true

        if let sublayer = matchProgressView.layer.sublayers?[safe: 1] {
            sublayer.cornerRadius = 4
        }
        if let subview = matchProgressView.subviews[safe: 1] {
            subview.clipsToBounds = true
        }
    }

    @objc func didTapOnTeam1FlagAction() {
        executeTapOnFlagClosureForIndex(0)
    }

    @objc func didTapOnTeam2FlagAction() {
        executeTapOnFlagClosureForIndex(1)
    }

    private func executeTapOnFlagClosureForIndex(_ index: Int) {
        guard let contestants = match?.contestants, contestants.count == 2 else { return }

        var teamId = ""
        if index == 0, let homeContestantId = contestants[0].id {
            teamId = homeContestantId
        } else if let awayContestantId = contestants[1].id {
            teamId = awayContestantId
        }

        if let didTapOnTeamFlag = didTapOnTeamFlag {
            didTapOnTeamFlag(teamId)
        }
    }
}
