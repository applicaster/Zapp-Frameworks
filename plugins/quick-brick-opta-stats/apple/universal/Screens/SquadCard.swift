//
//  PlayerCard.swift
//  CopaAmericaStatsScreenPlugin
//
//  Created by Jesus De Meyer on 3/12/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import Foundation
import SwiftyJSON

struct SquadCard {
    var squads = [Squad]()
    var squad: Squad? {
        return squads.first
    }

    var lastUpdated: Date?

    init(json: JSON) {
        squads.removeAll()

        if let squadList = json["squad"].array {
            for squadListInfo in squadList {
                guard let squadInfo = squadListInfo.dictionary else {
                    continue
                }

                var squad = Squad()

                squad.contestantId = squadInfo["contestantId"]?.string
                squad.contestantName = squadInfo["contestantName"]?.string
                squad.contestantShortName = squadInfo["contestantShortName"]?.string
                squad.contestantClubName = squadInfo["contestantClubName"]?.string
                squad.contestantCode = squadInfo["contestantCode"]?.string
                squad.tournamentCalendarId = squadInfo["tournamentCalendarId"]?.string
                squad.tournamentCalendarStartDate = Helpers.shortDate(from: json["tournamentCalendarStartDate"].string ?? "")
                squad.tournamentCalendarEndDate = Helpers.shortDate(from: json["tournamentCalendarEndDate"].string ?? "")
                squad.competitionName = squadInfo["competitionName"]?.string
                squad.competitionId = squadInfo["competitionId"]?.string
                squad.type = squadInfo["type"]?.string
                squad.teamType = squadInfo["teamType"]?.string
                squad.venueName = squadInfo["venueName"]?.string
                squad.venueId = squadInfo["venueId"]?.string

                var persons = [SquadPerson]()

                if let personList = squadInfo["person"]?.array {
                    for personListItem in personList {
                        guard let personInfo = personListItem.dictionary else {
                            continue
                        }

                        var person = SquadPerson()

                        person.id = personInfo["id"]?.string
                        person.firstName = personInfo["firstName"]?.string
                        person.lastName = personInfo["lastName"]?.string
                        person.matchName = personInfo["matchName"]?.string
                        person.nationality = personInfo["nationality"]?.string
                        person.nationalityId = personInfo["nationalityId"]?.string
                        person.position = personInfo["position"]?.string
                        person.type = personInfo["type"]?.string
                        person.dateOfBirth = Helpers.birthdayDate(from: personInfo["dateOfBirth"]?.string ?? "")
                        person.placeOfBirth = personInfo["placeOfBirth"]?.string
                        person.countryOfBirth = personInfo["countryOfBirth"]?.string
                        person.countryOfBirthId = personInfo["countryOfBirthId"]?.string
                        person.height = "\(personInfo["height"]?.int ?? 0)"
                        person.weight = "\(personInfo["weight"]?.int ?? 0)"
                        person.foot = personInfo["foot"]?.string
                        person.status = personInfo["status"]?.string
                        person.active = personInfo["active"]?.string
                        person.shirtNumber = personInfo["shirtNumber"]?.int

                        persons.append(person)
                    }
                }

                squad.persons = persons

                squads.append(squad)
            }
        }

        lastUpdated = Helpers.longDate(from: json["lastUpdated"].string ?? "")
    }
}
