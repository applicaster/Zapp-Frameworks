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
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var groupContainerView: UIView!
    @IBOutlet weak var groupDetailsContainerView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var toggleExpandButton: UIButton!
    
    // Group Container View
    
    @IBOutlet weak var groupTitleLabel: UILabel!
    
    @IBOutlet weak var group1FlagImageView: UIImageView!
    @IBOutlet weak var group1TeamLabel: UILabel!
    @IBOutlet weak var group1PointsLabel: UILabel!
    
    @IBOutlet weak var group2FlagImageView: UIImageView!
    @IBOutlet weak var group2TeamLabel: UILabel!
    @IBOutlet weak var group2PointsLabel: UILabel!
    
    @IBOutlet weak var group3FlagImageView: UIImageView!
    @IBOutlet weak var group3TeamLabel: UILabel!
    @IBOutlet weak var group3PointsLabel: UILabel!
    
    @IBOutlet weak var group4FlagImageView: UIImageView!
    @IBOutlet weak var group4TeamLabel: UILabel!
    @IBOutlet weak var group4PointsLabel: UILabel!
    
    // Group Details Container View
    
    @IBOutlet weak var detailsPlayedLabel: UILabel!
    @IBOutlet weak var detailsWonLabel: UILabel!
    @IBOutlet weak var detailsLostLabel: UILabel!
    @IBOutlet weak var detailsDrawLabel: UILabel!
    @IBOutlet weak var detailsGoalsInFavor: UILabel!
    @IBOutlet weak var detailsGoalsAgainst: UILabel!
    @IBOutlet weak var detailsAverage: UILabel!
    @IBOutlet weak var detailsPoints: UILabel!
    
    @IBOutlet weak var detailsGroup1FlagImageView: UIImageView!
    @IBOutlet weak var detailsGroup2FlagImageView: UIImageView!
    @IBOutlet weak var detailsGroup3FlagImageView: UIImageView!
    @IBOutlet weak var detailsGroup4FlagImageView: UIImageView!
    
    @IBOutlet weak var detailsGroup1PlayedLabel: UILabel!
    @IBOutlet weak var detailsGroup2PlayedLabel: UILabel!
    @IBOutlet weak var detailsGroup3PlayedLabel: UILabel!
    @IBOutlet weak var detailsGroup4PlayedLabel: UILabel!
    
    @IBOutlet weak var detailsGroup1WonLabel: UILabel!
    @IBOutlet weak var detailsGroup2WonLabel: UILabel!
    @IBOutlet weak var detailsGroup3WonLabel: UILabel!
    @IBOutlet weak var detailsGroup4WonLabel: UILabel!
    
    @IBOutlet weak var detailsGroup1DrawLabel: UILabel!
    @IBOutlet weak var detailsGroup2DrawLabel: UILabel!
    @IBOutlet weak var detailsGroup3DrawLabel: UILabel!
    @IBOutlet weak var detailsGroup4DrawLabel: UILabel!
    
    @IBOutlet weak var detailsGroup1LostLabel: UILabel!
    @IBOutlet weak var detailsGroup2LostLabel: UILabel!
    @IBOutlet weak var detailsGroup3LostLabel: UILabel!
    @IBOutlet weak var detailsGroup4LostLabel: UILabel!
    
    @IBOutlet weak var detailsGroup1GoalsFavorLabel: UILabel!
    @IBOutlet weak var detailsGroup2GoalsFavorLabel: UILabel!
    @IBOutlet weak var detailsGroup3GoalsFavorLabel: UILabel!
    @IBOutlet weak var detailsGroup4GoalsFavorLabel: UILabel!
    
    @IBOutlet weak var detailsGroup1GoalsAgainstLabel: UILabel!
    @IBOutlet weak var detailsGroup2GoalsAgainstLabel: UILabel!
    @IBOutlet weak var detailsGroup3GoalsAgainstLabel: UILabel!
    @IBOutlet weak var detailsGroup4GoalsAgainstLabel: UILabel!
    
    @IBOutlet weak var detailsGroup1GoalsAverageLabel: UILabel!
    @IBOutlet weak var detailsGroup2GoalsAverageLabel: UILabel!
    @IBOutlet weak var detailsGroup3GoalsAverageLabel: UILabel!
    @IBOutlet weak var detailsGroup4GoalsAverageLabel: UILabel!
    
    @IBOutlet weak var detailsGroup1PointsLabel: UILabel!
    @IBOutlet weak var detailsGroup2PointsLabel: UILabel!
    @IBOutlet weak var detailsGroup3PointsLabel: UILabel!
    @IBOutlet weak var detailsGroup4PointsLabel: UILabel!
    
    var isExpanded: Bool = false
    var isExpandable: Bool = true
    var cellHeight: CGFloat {
        return self.isExpanded ? expandedCellHeight : collapsedCellHeight
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
        collapsedCellHeight = groupContainerView.frame.height+separatorView.frame.height
        
        groupTitleLabel.useBoldFont()
        group1TeamLabel.useRegularFont()
        group1PointsLabel.useBoldFont()
        group2TeamLabel.useRegularFont()
        group2PointsLabel.useBoldFont()
        group3TeamLabel.useRegularFont()
        group3PointsLabel.useBoldFont()
        group4TeamLabel.useRegularFont()
        group4PointsLabel.useBoldFont()
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
        detailsGroup1WonLabel.useRegularFont()
        detailsGroup2WonLabel.useRegularFont()
        detailsGroup3WonLabel.useRegularFont()
        detailsGroup4WonLabel.useRegularFont()
        detailsGroup1DrawLabel.useRegularFont()
        detailsGroup2DrawLabel.useRegularFont()
        detailsGroup3DrawLabel.useRegularFont()
        detailsGroup4DrawLabel.useRegularFont()
        detailsGroup1LostLabel.useRegularFont()
        detailsGroup2LostLabel.useRegularFont()
        detailsGroup3LostLabel.useRegularFont()
        detailsGroup4LostLabel.useRegularFont()
        detailsGroup1GoalsFavorLabel.useRegularFont()
        detailsGroup2GoalsFavorLabel.useRegularFont()
        detailsGroup3GoalsFavorLabel.useRegularFont()
        detailsGroup4GoalsFavorLabel.useRegularFont()
        detailsGroup1GoalsAgainstLabel.useRegularFont()
        detailsGroup2GoalsAgainstLabel.useRegularFont()
        detailsGroup3GoalsAgainstLabel.useRegularFont()
        detailsGroup4GoalsAgainstLabel.useRegularFont()
        detailsGroup1GoalsAverageLabel.useRegularFont()
        detailsGroup2GoalsAverageLabel.useRegularFont()
        detailsGroup3GoalsAverageLabel.useRegularFont()
        detailsGroup4GoalsAverageLabel.useRegularFont()
        detailsGroup1PointsLabel.useRegularFont()
        detailsGroup2PointsLabel.useRegularFont()
        detailsGroup3PointsLabel.useRegularFont()
        detailsGroup4PointsLabel.useRegularFont()
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
            didTapOnToggleExpand(self.tag)
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
        guard let model = self.division else {
            return
        }
        
        groupTitleLabel.text = model.groupName?.uppercased()
        
        var unknownFlagImage = Helpers.unknownFlagImage()
        
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
    
    private func executeTapOnFlagClosureForIndex(_ index: Int) {
        guard let division = self.division, let rankings = division.rankings, let contestantId = rankings[safe: index]?.contestantID else { return }
        
        if let didTapOnTeamFlag = didTapOnTeamFlag {
            didTapOnTeamFlag(contestantId)
        }
    }
}
