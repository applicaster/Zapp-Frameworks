//
//  LineupTableViewCell.swift
//  CopaAmericaStatsScreenPlugin
//
//  Created by Jesus De Meyer on 4/23/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import UIKit

struct LineupTableViewCellPlayer {
    var identifier = ""
    var position = ""
    var name = ""
    var shirtNumber: String?

    init(player: Player) {
        identifier = player.id ?? ""
        name = player.matchName ?? ""
        position = player.position ?? ""
        if let shirt = player.shirtNumber {
            shirtNumber = shirt
        }
    }
}

class LineupTableViewCell: UITableViewCell {
    @IBOutlet var homePlayerContainerView: UIView!
    @IBOutlet var awayPlayerContainerView: UIView!

    @IBOutlet var homePlayerShirtNumberContainerView: UIView!
    @IBOutlet var awayPlayerShirtNumberContainerView: UIView!

    @IBOutlet var homePlayerPositionLabel: UILabel!
    @IBOutlet var homePlayerNameLabel: UILabel!

    @IBOutlet var awayPlayerPositionLabel: UILabel!
    @IBOutlet var awayPlayerNameLabel: UILabel!

    var didSelectHomePlayer: ((_ cell: LineupTableViewCell) -> Void)?
    var didSelectAwayPlayer: ((_ cell: LineupTableViewCell) -> Void)?

    var homePlayer: LineupTableViewCellPlayer? {
        didSet {
            updateUI()
        }
    }

    var awayPlayer: LineupTableViewCellPlayer? {
        didSet {
            updateUI()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        homePlayerPositionLabel.useBoldFont()
        homePlayerNameLabel.useRegularFont()

        awayPlayerPositionLabel.useBoldFont()
        awayPlayerNameLabel.useRegularFont()
        homePlayerContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectHomePlayer(_:))))
        awayPlayerContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectAwayPlayer(_:))))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    fileprivate func updateUI() {
        homePlayerNameLabel.text = homePlayer?.name ?? ""
        homePlayerPositionLabel.text = Localized.getLocalizedString(from: homePlayer?.position.capitalized ?? "").capitalized

        awayPlayerNameLabel.text = awayPlayer?.name ?? ""
        awayPlayerPositionLabel.text = Localized.getLocalizedString(from: awayPlayer?.position.capitalized ?? "").capitalized

        homePlayerShirtNumberContainerView.removeAllSubviews()
        awayPlayerShirtNumberContainerView.removeAllSubviews()

        if let value = homePlayer?.shirtNumber {
            let homePlayerShirtView = PlayerShirtView(text: value, radius: homePlayerShirtNumberContainerView.frame.height * 0.5)
            homePlayerShirtView.isHomeTeam = true
            homePlayerShirtNumberContainerView.addSubview(homePlayerShirtView)

            homePlayerShirtView.translatesAutoresizingMaskIntoConstraints = false

            homePlayerShirtNumberContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: [], metrics: nil, views: ["view": homePlayerShirtView]))
            homePlayerShirtNumberContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: [], metrics: nil, views: ["view": homePlayerShirtView]))
        }

        if let value = awayPlayer?.shirtNumber {
            let awayPlayerShirtView = PlayerShirtView(text: value, radius: homePlayerShirtNumberContainerView.frame.height * 0.5)
            awayPlayerShirtView.isHomeTeam = false
            awayPlayerShirtNumberContainerView.addSubview(awayPlayerShirtView)

            awayPlayerShirtView.translatesAutoresizingMaskIntoConstraints = false

            awayPlayerShirtNumberContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: [], metrics: nil, views: ["view": awayPlayerShirtView]))
            awayPlayerShirtNumberContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: [], metrics: nil, views: ["view": awayPlayerShirtView]))
        }
    }

    @objc
    func handleSelectHomePlayer(_ sender: UITapGestureRecognizer) {
        didSelectHomePlayer?(self)
    }

    @objc
    func handleSelectAwayPlayer(_ sender: UITapGestureRecognizer) {
        didSelectAwayPlayer?(self)
    }
}
