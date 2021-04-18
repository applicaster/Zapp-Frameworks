//
//  TeamCardPlayerTableViewCell.swift
//  CopaAmericaStatsScreenPlugin
//
//  Created by Marcos Reyes - Applicaster on 3/11/19.
//

import Foundation

class TeamCardPlayerTableViewCell: UITableViewCell {
    @IBOutlet var playerNumberLabel: UILabel!
    @IBOutlet var playerNameLabel: UILabel!
    @IBOutlet var playerPositionLabel: UILabel!
    @IBOutlet var playerImageView: UIImageView!

    var teamCardPlayerImageBaseURL: String?
    var person: SquadPerson? {
        didSet {
            updatePlayerInfo()
        }
    }

    var player: Player? {
        didSet {
            updatePlayerInfo()
        }
    }

    override func awakeFromNib() {
        contentView.backgroundColor = UIColor.white
        playerNumberLabel.text = ""
        playerNameLabel.text = ""
        playerPositionLabel.text = ""
        playerImageView.image = nil

        playerNameLabel.useBoldFont()
        playerNumberLabel.useBoldFont()
        playerPositionLabel.useBoldFont()
    }

    override func prepareForReuse() {
        playerNumberLabel.text = ""
        playerNameLabel.text = ""
        playerPositionLabel.text = ""
        playerImageView.image = nil
    }

    fileprivate func updatePlayerInfo() {
        if let _ = person {
            setPersonInfo()
        }
        // if let _ = self.player {
        //    setPlayerInfo()
        // }
    }

    private func setPersonInfo() {
        guard let person = person, let personId = person.id else { return }

        if let value = person.shirtNumber {
            playerNumberLabel.text = "\(value)"
        } else {
            playerNumberLabel.text = "-"
        }

        if let playerName = person.matchName, let text = playerNameLabel.text, text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            playerNameLabel.text = playerName
        }

        if let playerPosition = person.position, let text = playerPositionLabel.text, text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            playerPositionLabel.text = Localized.getLocalizedString(from: playerPosition.capitalized).uppercased()
        }
        if let type = person.type, type.uppercased() == "COACH" {
            playerPositionLabel.text = Localized.getLocalizedString(from: "COACH")
        }
        if let type = person.type, type.uppercased() == "ASSISTANT COACH" {
            playerPositionLabel.text = Localized.getLocalizedString(from: "ASSISTANT")
        }

        let imageBaseUrl = OptaStats.pluginParams.imageBaseUrl
        playerImageView.sd_setImage(with: URL(string: "\(imageBaseUrl)\(personId).png"), placeholderImage: nil)
    }

    private func setPlayerInfo() {
        guard let player = player, let playerId = player.id else { return }

        if let playerNumber = player.shirtNumber, let text = playerNumberLabel.text, text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || text == "-" {
            playerNumberLabel.text = playerNumber
        }

        if let playerName = player.matchName, let text = playerNameLabel.text, text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            playerNameLabel.text = playerName
        }

        if let playerPosition = player.position, let text = playerPositionLabel.text, text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            playerPositionLabel.text = Localized.getLocalizedString(from: playerPosition.capitalized).uppercased()
        }

        let imageBaseUrl = OptaStats.pluginParams.imageBaseUrl
        playerImageView.sd_setImage(with: URL(string: "\(imageBaseUrl)\(playerId).png"), placeholderImage: nil)
    }

    fileprivate func findPlayerShirtNumber(player: SquadPerson) -> String? {
        var result: String?

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
}
