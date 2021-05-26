//
//  GroupCardTableViewCell.swift
//  CopaAmericaStatsScreenPlugin
//
//  Created by Jesus De Meyer on 3/13/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import UIKit

protocol GroupCardTableViewCellDelegate {
    func groupCardTableViewCellUpdateExpanding(cell: GroupCardTableViewCell)
}

class GroupCardTableViewCell: UITableViewCell {
    var cellDelegate: GroupCardTableViewCellDelegate?
    var didTapOnTeamFlag: ((String) -> Void)?
    var didTapOnToggleExpand: ((Int) -> Void)?
    var team1FlagImageRecognizer: UITapGestureRecognizer?
    var team2FlagImageRecognizer: UITapGestureRecognizer?
    var team3FlagImageRecognizer: UITapGestureRecognizer?
    var team4FlagImageRecognizer: UITapGestureRecognizer?
    var team5FlagImageRecognizer: UITapGestureRecognizer?

    @IBOutlet var containerView: UIView!
    @IBOutlet var groupContainerView: UIView!
    @IBOutlet var groupDetailsContainerView: UIView!
    @IBOutlet var separatorView: UIView!
    @IBOutlet var toggleExpandButton: UIButton!

    // Group Container View

    @IBOutlet var groupTitleLabel: UILabel!

    @IBOutlet var group1FlagImageView: UIImageView!
    @IBOutlet var group1TeamLabel: UILabel!
    @IBOutlet var group1PointsLabel: UILabel!

    @IBOutlet var group2FlagImageView: UIImageView!
    @IBOutlet var group2TeamLabel: UILabel!
    @IBOutlet var group2PointsLabel: UILabel!

    @IBOutlet var group3FlagImageView: UIImageView!
    @IBOutlet var group3TeamLabel: UILabel!
    @IBOutlet var group3PointsLabel: UILabel!

    @IBOutlet var group4FlagImageView: UIImageView!
    @IBOutlet var group4TeamLabel: UILabel!
    @IBOutlet var group4PointsLabel: UILabel!

    @IBOutlet var group5FlagImageView: UIImageView!
    @IBOutlet var group5TeamLabel: UILabel!
    @IBOutlet var group5PointsLabel: UILabel!

    // Group Details Container View

    @IBOutlet var detailsPlayedLabel: UILabel!
    @IBOutlet var detailsWonLabel: UILabel!
    @IBOutlet var detailsLostLabel: UILabel!
    @IBOutlet var detailsDrawLabel: UILabel!
    @IBOutlet var detailsGoalsInFavor: UILabel!
    @IBOutlet var detailsGoalsAgainst: UILabel!
    @IBOutlet var detailsAverage: UILabel!
    @IBOutlet var detailsPoints: UILabel!

    @IBOutlet var detailsGroup1FlagImageView: UIImageView!
    @IBOutlet var detailsGroup2FlagImageView: UIImageView!
    @IBOutlet var detailsGroup3FlagImageView: UIImageView!
    @IBOutlet var detailsGroup4FlagImageView: UIImageView!
    @IBOutlet var detailsGroup5FlagImageView: UIImageView!

    @IBOutlet var detailsGroup1PlayedLabel: UILabel!
    @IBOutlet var detailsGroup2PlayedLabel: UILabel!
    @IBOutlet var detailsGroup3PlayedLabel: UILabel!
    @IBOutlet var detailsGroup4PlayedLabel: UILabel!
    @IBOutlet var detailsGroup5PlayedLabel: UILabel!

    @IBOutlet var detailsGroup1WonLabel: UILabel!
    @IBOutlet var detailsGroup2WonLabel: UILabel!
    @IBOutlet var detailsGroup3WonLabel: UILabel!
    @IBOutlet var detailsGroup4WonLabel: UILabel!
    @IBOutlet var detailsGroup5WonLabel: UILabel!

    @IBOutlet var detailsGroup1DrawLabel: UILabel!
    @IBOutlet var detailsGroup2DrawLabel: UILabel!
    @IBOutlet var detailsGroup3DrawLabel: UILabel!
    @IBOutlet var detailsGroup4DrawLabel: UILabel!
    @IBOutlet var detailsGroup5DrawLabel: UILabel!

    @IBOutlet var detailsGroup1LostLabel: UILabel!
    @IBOutlet var detailsGroup2LostLabel: UILabel!
    @IBOutlet var detailsGroup3LostLabel: UILabel!
    @IBOutlet var detailsGroup4LostLabel: UILabel!
    @IBOutlet var detailsGroup5LostLabel: UILabel!

    @IBOutlet var detailsGroup1GoalsFavorLabel: UILabel!
    @IBOutlet var detailsGroup2GoalsFavorLabel: UILabel!
    @IBOutlet var detailsGroup3GoalsFavorLabel: UILabel!
    @IBOutlet var detailsGroup4GoalsFavorLabel: UILabel!
    @IBOutlet var detailsGroup5GoalsFavorLabel: UILabel!

    @IBOutlet var detailsGroup1GoalsAgainstLabel: UILabel!
    @IBOutlet var detailsGroup2GoalsAgainstLabel: UILabel!
    @IBOutlet var detailsGroup3GoalsAgainstLabel: UILabel!
    @IBOutlet var detailsGroup4GoalsAgainstLabel: UILabel!
    @IBOutlet var detailsGroup5GoalsAgainstLabel: UILabel!

    @IBOutlet var detailsGroup1GoalsAverageLabel: UILabel!
    @IBOutlet var detailsGroup2GoalsAverageLabel: UILabel!
    @IBOutlet var detailsGroup3GoalsAverageLabel: UILabel!
    @IBOutlet var detailsGroup4GoalsAverageLabel: UILabel!
    @IBOutlet var detailsGroup5GoalsAverageLabel: UILabel!

    @IBOutlet var detailsGroup1PointsLabel: UILabel!
    @IBOutlet var detailsGroup2PointsLabel: UILabel!
    @IBOutlet var detailsGroup3PointsLabel: UILabel!
    @IBOutlet var detailsGroup4PointsLabel: UILabel!
    @IBOutlet var detailsGroup5PointsLabel: UILabel!

    var isExpanded: Bool = false
    var isExpandable: Bool = true
    var cellHeight: CGFloat {
        return isExpanded ? expandedCellHeight : collapsedCellHeight
    }

    fileprivate var expandedCellHeight: CGFloat = 0.0
    fileprivate var collapsedCellHeight: CGFloat = 0.0

    var division: Division? {
        didSet {
            updateUI()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        containerView.layer.cornerRadius = 9.0
        containerView.layer.shadowRadius = 20.0
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        containerView.layer.shadowColor = UIColor.black.cgColor

        separatorView.alpha = 0

        expandedCellHeight = groupContainerView.frame.height + groupDetailsContainerView.frame.height + separatorView.frame.height
        collapsedCellHeight = groupContainerView.frame.height + separatorView.frame.height

        groupTitleLabel.useBoldFont()
        group1TeamLabel.useRegularFont()
        group1PointsLabel.useBoldFont()

        group2TeamLabel.useRegularFont()
        group2PointsLabel.useBoldFont()

        group3TeamLabel.useRegularFont()
        group3PointsLabel.useBoldFont()

        group4TeamLabel.useRegularFont()
        group4PointsLabel.useBoldFont()

        group5TeamLabel.useRegularFont()
        group5PointsLabel.useBoldFont()

        detailsPlayedLabel.useBoldFont()
        detailsWonLabel.useBoldFont()
        detailsLostLabel.useBoldFont()
        detailsDrawLabel.useBoldFont()
        detailsGoalsInFavor.useBoldFont()
        detailsGoalsAgainst.useBoldFont()
        detailsAverage.useBoldFont()
        detailsPoints.useBoldFont()

        detailsGroup1PlayedLabel.useRegularFont()
        detailsGroup2PlayedLabel.useRegularFont()
        detailsGroup3PlayedLabel.useRegularFont()
        detailsGroup4PlayedLabel.useRegularFont()
        detailsGroup5PlayedLabel.useRegularFont()

        detailsGroup1WonLabel.useRegularFont()
        detailsGroup2WonLabel.useRegularFont()
        detailsGroup3WonLabel.useRegularFont()
        detailsGroup4WonLabel.useRegularFont()
        detailsGroup5WonLabel.useRegularFont()

        detailsGroup1DrawLabel.useRegularFont()
        detailsGroup2DrawLabel.useRegularFont()
        detailsGroup3DrawLabel.useRegularFont()
        detailsGroup4DrawLabel.useRegularFont()
        detailsGroup5DrawLabel.useRegularFont()

        detailsGroup1LostLabel.useRegularFont()
        detailsGroup2LostLabel.useRegularFont()
        detailsGroup3LostLabel.useRegularFont()
        detailsGroup4LostLabel.useRegularFont()
        detailsGroup5LostLabel.useRegularFont()

        detailsGroup1GoalsFavorLabel.useRegularFont()
        detailsGroup2GoalsFavorLabel.useRegularFont()
        detailsGroup3GoalsFavorLabel.useRegularFont()
        detailsGroup4GoalsFavorLabel.useRegularFont()
        detailsGroup5GoalsFavorLabel.useRegularFont()

        detailsGroup1GoalsAgainstLabel.useRegularFont()
        detailsGroup2GoalsAgainstLabel.useRegularFont()
        detailsGroup3GoalsAgainstLabel.useRegularFont()
        detailsGroup4GoalsAgainstLabel.useRegularFont()
        detailsGroup5GoalsAgainstLabel.useRegularFont()

        detailsGroup1GoalsAverageLabel.useRegularFont()
        detailsGroup2GoalsAverageLabel.useRegularFont()
        detailsGroup3GoalsAverageLabel.useRegularFont()
        detailsGroup4GoalsAverageLabel.useRegularFont()
        detailsGroup5GoalsAverageLabel.useRegularFont()

        detailsGroup1PointsLabel.useRegularFont()
        detailsGroup2PointsLabel.useRegularFont()
        detailsGroup3PointsLabel.useRegularFont()
        detailsGroup4PointsLabel.useRegularFont()
        detailsGroup5PointsLabel.useRegularFont()
    }

    override func prepareForReuse() {
        didTapOnTeamFlag = nil
        didTapOnToggleExpand = nil
        if let team1FlagImageRecognizer = team1FlagImageRecognizer {
            group1FlagImageView.removeGestureRecognizer(team1FlagImageRecognizer)
        }
        if let team2FlagImageRecognizer = team2FlagImageRecognizer {
            group2FlagImageView.removeGestureRecognizer(team2FlagImageRecognizer)
        }
        if let team3FlagImageRecognizer = team3FlagImageRecognizer {
            group3FlagImageView.removeGestureRecognizer(team3FlagImageRecognizer)
        }
        if let team4FlagImageRecognizer = team4FlagImageRecognizer {
            group4FlagImageView.removeGestureRecognizer(team4FlagImageRecognizer)
        }
        if let team5FlagImageRecognizer = team5FlagImageRecognizer {
            group5FlagImageView.removeGestureRecognizer(team5FlagImageRecognizer)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func toggleExpand(_ sender: Any) {
        if !isExpandable {
            return
        }

        if let didTapOnToggleExpand = didTapOnToggleExpand {
            didTapOnToggleExpand(tag)
        }

        isExpanded = !isExpanded

        UIView.animate(withDuration: 0.25, animations: {
            var transformToUse: CGAffineTransform = .identity
            transformToUse = self.isExpanded ? CGAffineTransform(rotationAngle: CGFloat(Double.pi)) : .identity
            self.toggleExpandButton.transform = transformToUse
        })

        cellDelegate?.groupCardTableViewCellUpdateExpanding(cell: self)

        UIView.animate(withDuration: 0.25) {
            self.separatorView.alpha = self.isExpanded ? 1.0 : 0.0
            self.groupDetailsContainerView.alpha = self.isExpanded ? 1.0 : 0.0
        }
    }

    func updateUI() {
        guard let model = division else {
            return
        }

        groupTitleLabel.text = model.groupName?.uppercased()

        let unknownFlagImage = Helpers.unknownFlagImage()

        if let rankings = model.rankings {
            for ranking in rankings {
                var flagImageView: UIImageView?
                var teamLabel: UILabel?
                var pointsLabel: UILabel?

                var detailsFlagImageView: UIImageView?
                var detailsGroupPlayedLabel: UILabel?
                var detailsGroupWonLabel: UILabel?
                var detailsGroupLostLabel: UILabel?
                var detailsGroupDrawLabel: UILabel?
                var detailsGoalsInFavor: UILabel?
                var detailsGoalsAgainst: UILabel?
                var detailsAverage: UILabel?
                var detailsPoints: UILabel?

                if let rank = ranking.rank {
                    switch rank {
                    case 1:
                        flagImageView = group1FlagImageView
                        teamLabel = group1TeamLabel
                        pointsLabel = group1PointsLabel
                        detailsFlagImageView = detailsGroup1FlagImageView
                        detailsGroupPlayedLabel = detailsGroup1PlayedLabel
                        detailsGroupWonLabel = detailsGroup1WonLabel
                        detailsGroupLostLabel = detailsGroup1LostLabel
                        detailsGroupDrawLabel = detailsGroup1DrawLabel
                        detailsGoalsInFavor = detailsGroup1GoalsFavorLabel
                        detailsGoalsAgainst = detailsGroup1GoalsAgainstLabel
                        detailsAverage = detailsGroup1GoalsAverageLabel
                        detailsPoints = detailsGroup1PointsLabel

                        if let _ = didTapOnTeamFlag {
                            team1FlagImageRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnTeam1FlagAction))
                            if let team1FlagImageRecognizer = team1FlagImageRecognizer {
                                group1FlagImageView.isUserInteractionEnabled = true
                                group1FlagImageView.addGestureRecognizer(team1FlagImageRecognizer)
                            }
                        }
                    case 2:
                        flagImageView = group2FlagImageView
                        teamLabel = group2TeamLabel
                        pointsLabel = group2PointsLabel
                        detailsFlagImageView = detailsGroup2FlagImageView
                        detailsGroupPlayedLabel = detailsGroup2PlayedLabel
                        detailsGroupWonLabel = detailsGroup2WonLabel
                        detailsGroupLostLabel = detailsGroup2LostLabel
                        detailsGroupDrawLabel = detailsGroup2DrawLabel
                        detailsGoalsInFavor = detailsGroup2GoalsFavorLabel
                        detailsGoalsAgainst = detailsGroup2GoalsAgainstLabel
                        detailsAverage = detailsGroup2GoalsAverageLabel
                        detailsPoints = detailsGroup2PointsLabel

                        if let _ = didTapOnTeamFlag {
                            team2FlagImageRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnTeam2FlagAction))
                            if let team2FlagImageRecognizer = team2FlagImageRecognizer {
                                group2FlagImageView.isUserInteractionEnabled = true
                                group2FlagImageView.addGestureRecognizer(team2FlagImageRecognizer)
                            }
                        }
                    case 3:
                        flagImageView = group3FlagImageView
                        teamLabel = group3TeamLabel
                        pointsLabel = group3PointsLabel
                        detailsFlagImageView = detailsGroup3FlagImageView
                        detailsGroupPlayedLabel = detailsGroup3PlayedLabel
                        detailsGroupWonLabel = detailsGroup3WonLabel
                        detailsGroupLostLabel = detailsGroup3LostLabel
                        detailsGroupDrawLabel = detailsGroup3DrawLabel
                        detailsGoalsInFavor = detailsGroup3GoalsFavorLabel
                        detailsGoalsAgainst = detailsGroup3GoalsAgainstLabel
                        detailsAverage = detailsGroup3GoalsAverageLabel
                        detailsPoints = detailsGroup3PointsLabel

                        if let _ = didTapOnTeamFlag {
                            team3FlagImageRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnTeam3FlagAction))
                            if let team3FlagImageRecognizer = team3FlagImageRecognizer {
                                group3FlagImageView.isUserInteractionEnabled = true
                                group3FlagImageView.addGestureRecognizer(team3FlagImageRecognizer)
                            }
                        }
                    case 4:
                        flagImageView = group4FlagImageView
                        teamLabel = group4TeamLabel
                        pointsLabel = group4PointsLabel
                        detailsFlagImageView = detailsGroup4FlagImageView
                        detailsGroupPlayedLabel = detailsGroup4PlayedLabel
                        detailsGroupWonLabel = detailsGroup4WonLabel
                        detailsGroupLostLabel = detailsGroup4LostLabel
                        detailsGroupDrawLabel = detailsGroup4DrawLabel
                        detailsGoalsInFavor = detailsGroup4GoalsFavorLabel
                        detailsGoalsAgainst = detailsGroup4GoalsAgainstLabel
                        detailsAverage = detailsGroup4GoalsAverageLabel
                        detailsPoints = detailsGroup4PointsLabel

                        if let _ = didTapOnTeamFlag {
                            team4FlagImageRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnTeam4FlagAction))
                            if let team4FlagImageRecognizer = team4FlagImageRecognizer {
                                group4FlagImageView.isUserInteractionEnabled = true
                                group4FlagImageView.addGestureRecognizer(team4FlagImageRecognizer)
                            }
                        }
                    case 5:
                        flagImageView = group5FlagImageView
                        teamLabel = group5TeamLabel
                        pointsLabel = group5PointsLabel
                        detailsFlagImageView = detailsGroup5FlagImageView
                        detailsGroupPlayedLabel = detailsGroup5PlayedLabel
                        detailsGroupWonLabel = detailsGroup5WonLabel
                        detailsGroupLostLabel = detailsGroup5LostLabel
                        detailsGroupDrawLabel = detailsGroup5DrawLabel
                        detailsGoalsInFavor = detailsGroup5GoalsFavorLabel
                        detailsGoalsAgainst = detailsGroup5GoalsAgainstLabel
                        detailsAverage = detailsGroup5GoalsAverageLabel
                        detailsPoints = detailsGroup5PointsLabel

                        if let _ = didTapOnTeamFlag {
                            team5FlagImageRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnTeam5FlagAction))
                            if let team5FlagImageRecognizer = team5FlagImageRecognizer {
                                group5FlagImageView.isUserInteractionEnabled = true
                                group5FlagImageView.addGestureRecognizer(team5FlagImageRecognizer)
                            }
                        }
                    default:
                        break
                    }
                }

                if let contestantID = ranking.contestantID {
                    let flagImageUrl = "\(OptaStats.pluginParams.imageBaseUrl)flag-\(contestantID).png"
                    flagImageView?.sd_setImage(with: URL(string: flagImageUrl), placeholderImage: nil)
                    detailsFlagImageView?.sd_setImage(with: URL(string: flagImageUrl), placeholderImage: nil)
                } else {
                    flagImageView?.image = unknownFlagImage
                    detailsFlagImageView?.image = unknownFlagImage
                }
                teamLabel?.text = ranking.contestantCode?.uppercased()
                pointsLabel?.text = "\(ranking.points ?? 0)"
                detailsGroupPlayedLabel?.text = "\(ranking.matchesPlayed ?? 0)"
                detailsGroupWonLabel?.text = "\(ranking.matchesWon ?? 0)"
                detailsGroupDrawLabel?.text = "\(ranking.matchesDrawn ?? 0)"
                detailsGroupLostLabel?.text = "\(ranking.matchesLost ?? 0)"
                detailsGoalsInFavor?.text = "\(ranking.goalsFor ?? 0)"
                detailsGoalsAgainst?.text = "\(ranking.goalsAgainst ?? 0)"
                detailsAverage?.text = "\(ranking.goalDifference ?? "-")"
                detailsPoints?.text = "\(ranking.points ?? 0)"
            }
        }
    }

    @objc func didTapOnTeam1FlagAction() {
        executeTapOnFlagClosureForIndex(0)
    }

    @objc func didTapOnTeam2FlagAction() {
        executeTapOnFlagClosureForIndex(1)
    }

    @objc func didTapOnTeam3FlagAction() {
        executeTapOnFlagClosureForIndex(2)
    }

    @objc func didTapOnTeam4FlagAction() {
        executeTapOnFlagClosureForIndex(3)
    }

    @objc func didTapOnTeam5FlagAction() {
        executeTapOnFlagClosureForIndex(4)
    }

    private func executeTapOnFlagClosureForIndex(_ index: Int) {
        guard let division = self.division, let rankings = division.rankings, let contestantId = rankings[safe: index]?.contestantID else { return }

        if let didTapOnTeamFlag = didTapOnTeamFlag {
            didTapOnTeamFlag(contestantId)
        }
    }
}
