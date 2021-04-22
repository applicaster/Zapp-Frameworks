//
//  MatchView.swift
//  CopaAmericaStatsScreenPlugin
//
//  Created by Jesus De Meyer on 4/10/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import UIKit

class MatchView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet var dottedImageView: UIImageView!
    @IBOutlet var containerView: UIView!

    @IBOutlet var matchDateLabel: UILabel!
    @IBOutlet var matchStageLabel: UILabel!
    @IBOutlet var matchLocationLabel: UILabel!
    @IBOutlet var matchLocationImageView: UIImageView!

    @IBOutlet var team1FlagImageView: UIImageView!
    @IBOutlet var team1CountryLabel: UILabel!
    @IBOutlet var team1GoalsLabel: UILabel!

    @IBOutlet var team2FlagImageView: UIImageView!
    @IBOutlet var team2CountryLabel: UILabel!
    @IBOutlet var team2GoalsLabel: UILabel!

    @IBOutlet var gamePeriodLabel: UILabel!
    @IBOutlet var gameTimeLabel: UILabel!
    @IBOutlet var gameTimeProgressView: UIProgressView!
    @IBOutlet var penaltiesContainerView: UIView!
    @IBOutlet var penaltiesLabel: UILabel!
    @IBOutlet var homePenaltyScoreLabel: UILabel!
    @IBOutlet var awayPenaltyScoreLabel: UILabel!

    @IBOutlet var moreInfoImageView: UIImageView?

    var didTapOnView: (() -> Void)?
    var didTapOnTeamFlag: ((String) -> Void)?

    fileprivate var team1FlagImageRecognizer: UITapGestureRecognizer?
    fileprivate var team2FlagImageRecognizer: UITapGestureRecognizer?
    fileprivate var viewRecognizer: UITapGestureRecognizer?

    var matchStat: MatchStatsCard? {
        didSet {
            updateUI()
        }
    }

    var hasDottedLines: Bool = true {
        didSet {
            updateUI()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }

    fileprivate func commonInit() {
        let nib = UINib(nibName: "MatchView", bundle: Bundle(for: classForCoder))
        if let view = nib.instantiate(withOwner: self, options: nil).first as? UIView {
            view.translatesAutoresizingMaskIntoConstraints = false

            addSubview(view)
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: [], metrics: nil, views: ["view": view]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: [], metrics: nil, views: ["view": view]))

            syncUI()

            updateUI()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        containerView.layer.cornerRadius = 9
        penaltiesContainerView.layer.cornerRadius = 4
        gameTimeProgressView.layer.cornerRadius = gameTimeProgressView.frame.height / 2
        gameTimeProgressView.clipsToBounds = true

        syncUI()
    }

    fileprivate func syncUI() {
        matchDateLabel.useRegularFont()
        matchStageLabel.useBoldFont()
        team1CountryLabel.useRegularFont()
        team2CountryLabel.useRegularFont()
        team1GoalsLabel.useBoldFont()
        team2GoalsLabel.useBoldFont()
        gamePeriodLabel.useBoldFont()
        gameTimeLabel.useBoldFont()
        penaltiesLabel.useRegularFont()
        matchLocationLabel.useBoldFont()
    }

    func reset() {
        didTapOnTeamFlag = nil
        if let team1FlagImageRecognizer = team1FlagImageRecognizer {
            team1FlagImageView.removeGestureRecognizer(team1FlagImageRecognizer)
        }
        if let team2FlagImageRecognizer = team2FlagImageRecognizer {
            team2FlagImageView.removeGestureRecognizer(team2FlagImageRecognizer)
        }
        if let viewRecognizer = viewRecognizer {
            removeGestureRecognizer(viewRecognizer)
        }
        roundProgressView()
    }

    fileprivate func updateUI() {
        resetUI()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, dd MMMM - HH:mm"

        if let date = matchStat?.matchInfo.date {
            let text = dateFormatter.string(from: date)
            matchDateLabel.text = "\(text)H".uppercased()
        } else {
            matchDateLabel.text = ""
        }

        matchStageLabel.text = matchStat?.matchInfo.stage?.name?.uppercased() ?? ""
        matchLocationLabel.text = matchStat?.matchInfo.venue?.shortName?.uppercased() ?? ""

        team1FlagImageView.image = Helpers.unknownFlagImage()
        team2FlagImageView.image = Helpers.unknownFlagImage()

        if let contestants = matchStat?.matchInfo.contestants {
            for (index, contestant) in contestants.enumerated() {
                let flagImageUrl = "\(OptaStats.pluginParams.imageBaseUrl)flag-\(contestant.id ?? "").png"

                switch index {
                case 0:
                    team1CountryLabel.text = contestant.code?.uppercased()
                    team1FlagImageView.sd_setImage(with: URL(string: flagImageUrl), placeholderImage: nil)
                case 1:
                    team2CountryLabel.text = contestant.code?.uppercased()
                    team2FlagImageView.sd_setImage(with: URL(string: flagImageUrl), placeholderImage: nil)
                default:
                    break
                }
            }
        }

        let matchDetails = matchStat?.liveData.matchDetails

        team1GoalsLabel.text = "-"
        team2GoalsLabel.text = "-"

        if let details = matchDetails, details.matchStatus?.lowercased() != "fixture" {
            team1GoalsLabel.text = "0"
            team2GoalsLabel.text = "0"

            if let value = details.scores?.et?.home {
                team1GoalsLabel.text = "\(value)"
            } else if let value = details.scores?.ft?.home {
                team1GoalsLabel.text = "\(value)"
            } else if let value = details.scores?.ht?.home {
                team1GoalsLabel.text = "\(value)"
            } else if let value = details.scores?.total?.home {
                team1GoalsLabel.text = "\(value)"
            }
            if let value = details.scores?.et?.away {
                team2GoalsLabel.text = "\(value)"
            } else if let value = details.scores?.ft?.away {
                team2GoalsLabel.text = "\(value)"
            } else if let value = details.scores?.ht?.away {
                team2GoalsLabel.text = "\(value)"
            } else if let value = details.scores?.total?.away {
                team2GoalsLabel.text = "\(value)"
            }
        }

        if let matchStatus = matchDetails?.matchStatus {
            switch matchStatus.uppercased() {
            case "PLAYING", "PLAYED":
                gamePeriodLabel.text = Localized.getLocalizedString(from: matchStatus.uppercased())
            default:
                gamePeriodLabel.text = " "
            }
        } else {
            gamePeriodLabel.text = " "
        }

        if let matchTime = matchDetails?.matchTime {
            updateMatchTime(matchTime)
        } else if let periods = matchDetails?.periods {
            var time = 0

            for period in periods {
                if let min = period.lengthMin {
                    time += min
                }
                if let sec = period.lengthSec {
                    time += sec > 30 ? 1 : 0
                }
            }
            updateMatchTime(time)
        } else {
            gameTimeLabel.text = ""
            gameTimeProgressView.progress = 0.0
        }

        if matchStat?.isHalfTime() ?? false {
            gameTimeLabel.text = Localized.getLocalizedString(from: "HALF TIME")
        }

        if let _ = matchDetails?.scores?.pen {
            penaltiesContainerView.isHidden = false
            homePenaltyScoreLabel.isHidden = false
            awayPenaltyScoreLabel.isHidden = false

            if let value = matchDetails?.scores?.et?.home {
                team1GoalsLabel.text = "\(value)"
            } else if let value = matchDetails?.scores?.ft?.home {
                team1GoalsLabel.text = "\(value)"
            }
            if let value = matchDetails?.scores?.et?.away {
                team2GoalsLabel.text = "\(value)"
            } else if let value = matchDetails?.scores?.ft?.away {
                team2GoalsLabel.text = "\(value)"
            }
            if let value = matchDetails?.scores?.total?.home {
                homePenaltyScoreLabel.text = "\(value)"
            } else {
                homePenaltyScoreLabel.text = "-"
            }
            if let value = matchDetails?.scores?.total?.away {
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

        if let _ = didTapOnTeamFlag {
            team1FlagImageRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnTeam1FlagAction))
            if let team1FlagImageRecognizer = team1FlagImageRecognizer {
                team1FlagImageView.isUserInteractionEnabled = true
                team1FlagImageView.addGestureRecognizer(team1FlagImageRecognizer)
            }

            team2FlagImageRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnTeam2FlagAction))
            if let team2FlagImageRecognizer = team2FlagImageRecognizer {
                team2FlagImageView.isUserInteractionEnabled = true
                team2FlagImageView.addGestureRecognizer(team2FlagImageRecognizer)
            }
        }

        if let _ = didTapOnView {
            viewRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnViewAction(_:)))
            isUserInteractionEnabled = true
            addGestureRecognizer(viewRecognizer!)
        }

        dottedImageView.isHidden = !hasDottedLines
        if !hasDottedLines {
            containerView.backgroundColor = .white
        }
    }

    fileprivate func resetUI() {
        matchDateLabel.text = ""

        matchStageLabel.text = ""
        matchLocationLabel.text = ""

        team1FlagImageView.image = Helpers.unknownFlagImage()
        team2FlagImageView.image = Helpers.unknownFlagImage()

        team1CountryLabel.text = "-"
        team2CountryLabel.text = "-"

        team1GoalsLabel.text = "-"
        team2GoalsLabel.text = "-"

        gamePeriodLabel.text = " "

        gameTimeLabel.text = ""
        gameTimeProgressView.progress = 0.0

        penaltiesContainerView.isHidden = true
        homePenaltyScoreLabel.text = "-"
        awayPenaltyScoreLabel.text = "-"
        homePenaltyScoreLabel.isHidden = true
        awayPenaltyScoreLabel.isHidden = true

        dottedImageView.isHidden = !hasDottedLines

        if !hasDottedLines {
            containerView.backgroundColor = .white
        }
    }

    fileprivate func updateMatchTime(_ time: Int) {
        gameTimeLabel.text = "\(time)'" // gameFinished ? "" : "\(gameTimeMin)'"

        let totalGameTimeInMins = 90
        let percent = (100.0 / Float(totalGameTimeInMins)) * Float(time)
        gameTimeProgressView.progress = percent >= 100.0 ? 1.0 : percent / 100.0
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        roundProgressView()
    }

    private func roundProgressView() {
        gameTimeProgressView.layer.cornerRadius = 4
        gameTimeProgressView.clipsToBounds = true

        if let sublayer = gameTimeProgressView.layer.sublayers?[safe: 1] {
            sublayer.cornerRadius = 4
        }
        if let subview = gameTimeProgressView.subviews[safe: 1] {
            subview.clipsToBounds = true
        }
    }

    @objc func didTapOnTeam1FlagAction() {
        executeTapOnFlagClosureForIndex(0)
    }

    @objc func didTapOnTeam2FlagAction() {
        executeTapOnFlagClosureForIndex(1)
    }

    @objc func didTapOnViewAction(_ sender: UITapGestureRecognizer) {
        didTapOnView?()
    }

    // MARK: -

    private func executeTapOnFlagClosureForIndex(_ index: Int) {
        guard let contestants = matchStat?.matchInfo.contestants, let teamId = contestants[safe: index]?.id else { return }

        didTapOnTeamFlag?(teamId)
    }
}
