//
//  SquadCareerCard.swift
//  CopaAmericaStatsScreenPlugin
//
//  Created by Jesus De Meyer on 3/12/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import Foundation
import SwiftyJSON

struct SquadCareerCard {
    var persons = [SquadPerson]()
    var person: SquadPerson? {
        return persons.first
    }

    var lastUpdated: Date?

    init(json: JSON) {
        if let personItemList = json["person"].array {
            persons.removeAll()

            for personItemInfo in personItemList {
                guard let personInfo = personItemInfo.dictionary else {
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
                person.height = personInfo["height"]?.string
                person.weight = personInfo["weight"]?.string
                person.foot = personInfo["foot"]?.string
                person.status = personInfo["status"]?.string
                person.active = personInfo["active"]?.string
                person.gender = personInfo["gender"]?.string
                person.lastUpdated = Helpers.longDate(from: personItemInfo["lastUpdated"].string ?? "")

                if let membershipItemList = personInfo["membership"]?.array {
                    var memberships = [SquadMembership]()

                    for membershipItem in membershipItemList {
                        guard let membershipInfo = membershipItem.dictionary else {
                            continue
                        }

                        var membership = SquadMembership()

                        membership.contestantId = membershipInfo["contestantId"]?.string
                        membership.contestantType = membershipInfo["contestantType"]?.string
                        membership.contestantName = membershipInfo["contestantName"]?.string
                        membership.active = membershipInfo["active"]?.string
                        membership.startDate = Helpers.shortDate(from: membershipInfo["startDate"]?.string ?? "")
                        membership.role = membershipInfo["role"]?.string
                        membership.type = membershipInfo["type"]?.string
                        membership.transferType = membershipInfo["transferType"]?.string

                        if let statItemList = membershipInfo["stat"]?.array {
                            var stats = [SquadStat]()

                            for statItem in statItemList {
                                guard let statInfo = statItem.dictionary else {
                                    continue
                                }

                                var stat = SquadStat()

                                stat.competitionId = statInfo["competitionId"]?.string
                                stat.competitionName = statInfo["competitionName"]?.string
                                stat.tournamentCalendarId = statInfo["tournamentCalendarId"]?.string
                                stat.tournamentCalendarName = statInfo["tournamentCalendarName"]?.string
                                stat.goals = statInfo["goals"]?.int
                                stat.assists = statInfo["assists"]?.int
                                stat.penaltyGoals = statInfo["penaltyGoals"]?.int
                                stat.appearances = statInfo["appearances"]?.int
                                stat.yellowCards = statInfo["yellowCards"]?.int
                                stat.secondYellowCards = statInfo["secondYellowCards"]?.int
                                stat.redCards = statInfo["redCards"]?.int
                                stat.substituteIn = statInfo["substituteIn"]?.int
                                stat.substituteOut = statInfo["substituteOut"]?.int
                                stat.subsOnBench = statInfo["subsOnBench"]?.int
                                stat.minutesPlayed = statInfo["minutesPlayed"]?.int
                                stat.shirtNumber = statInfo["shirtNumber"]?.int
                                stat.competitionFormat = statInfo["competitionFormat"]?.string
                                stat.isFriendly = statInfo["isFriendly"]?.string

                                stats.append(stat)
                            }

                            membership.stats = stats
                        }

                        memberships.append(membership)
                    }

                    person.memberships = memberships
                }

                persons.append(person)
            }
        }

        lastUpdated = Helpers.longDate(from: json["lastUpdated"].string ?? "")
    }
}
