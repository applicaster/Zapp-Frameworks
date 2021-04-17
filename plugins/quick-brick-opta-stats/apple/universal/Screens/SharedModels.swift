//
//  SharedModels.swift
//  CopaAmericaStatsScreenPlugin
//
//  Created by Marcos Reyes - Applicaster on 3/8/19.
//

import Foundation

struct TournamentCalendar {
    var id: String?
    var name: String?
    var startDate: Date?
    var endDate: Date?
    var lastUpdated: Date?
}

struct Competition {
    var id: String?
    var name: String?

    var code: String?
    var format: String?
    var lastUpdated: Date?
    var country: Country?
}

struct Player {
    var id: String?
    var position: String?
    var positionSide: String?
    var shirtNumber: String?
    var firstName: String?
    var lastName: String?
    var matchName: String?
    var stats: [Stat]?
    var subPosition: String?
}

struct Stage {
    var id: String?
    var formatId: String?
    var name: String?
    var vertical: Int?
    var startDate: Date?
    var endDate: Date?
    var divisions: [Division]?
}

struct Stat {
    var name: String?
    var type: String?
    var value: Double?
    var valueString: String?
}

struct Sport {
    var id: String?
    var name: String?
}

struct RuleSet {
    var id: String?
    var name: String?
}

struct Country {
    var id: String?
    var name: String?
}

struct Series {
    var id: String?
    var name: String?
}

struct Division {
    var type: String?
    var groupID: String?
    var groupName: String?
    var horizontal: Int?
    var rankings: [Ranking]?
}

struct Ranking {
    var rank: Int?
    var rankStatus: String?
    var rankID: String?
    var contestantID: String?
    var contestantName: String?
    var contestantShortName: String?
    var contestantClubName: String?
    var contestantCode: String?
    var points: Int?
    var matchesPlayed: Int?
    var matchesWon: Int?
    var matchesLost: Int?
    var matchesDrawn: Int?
    var goalsFor: Int?
    var goalsAgainst: Int?
    var goalDifference: String?
}

struct MatchDetail {
    var id: String?
    var date: Date?
    var week: String?
    var lastUpdated: Date?
    var description: String?
    var sport: Sport?
    var ruleSet: RuleSet?
    var competition: Competition?
    var tournamentCalendar: TournamentCalendar?
    var stage: Stage?
    var series: Series?
    var contestants: [Contestant]?
    var venue: Venue?
    var liveData: LiveData?
}

struct Contestant {
    var id: String?
    var name: String?
    var shortName: String?
    var officialName: String?
    var code: String?
    var position: String?
    var country: Country?
}

struct ContestantStat {
    var id: String?
    var name: String?
    var stat: [Stat]?
}

struct Venue {
    var id: String?
    var neutral: String?
    var longName: String?
    var shortName: String?
}

struct MatchDate {
    var date: Date?
    var numberOfGames: String?
    var matches: [Match]?
}

struct Match {
    var id: String?
    var coverageLevel: String?
    var date: Date?
    var homeContestantId: String?
    var awayContestantId: String?
    var homeContestantName: String?
    var awayContestantName: String?
    var homeContestantOfficialName: String?
    var awayContestantOfficialName: String?
    var homeContestantShortName: String?
    var awayContestantShortName: String?
    var homeContestantCode: String?
    var awayContestantCode: String?
}

struct Squad {
    var contestantId: String?
    var contestantName: String?
    var contestantShortName: String?
    var contestantClubName: String?
    var contestantCode: String?
    var tournamentCalendarId: String?
    var tournamentCalendarStartDate: Date?
    var tournamentCalendarEndDate: Date?
    var competitionName: String?
    var competitionId: String?
    var type: String?
    var teamType: String?
    var venueName: String?
    var venueId: String?
    var persons: [SquadPerson]?
}

struct SquadPerson {
    var id: String?
    var firstName: String?
    var lastName: String?
    var matchName: String?
    var nationality: String?
    var nationalityId: String?
    var position: String?
    var type: String?
    var dateOfBirth: Date?
    var placeOfBirth: String?
    var countryOfBirth: String?
    var countryOfBirthId: String?
    var height: String?
    var weight: String?
    var foot: String?
    var status: String?
    var active: String?
    var lastUpdated: Date?
    var gender: String?
    var shirtNumber: Int?
    var memberships: [SquadMembership]?
}

struct SquadMembership {
    var contestantId: String?
    var contestantType: String?
    var contestantName: String?
    var active: String?
    var startDate: Date?
    var role: String?
    var type: String?
    var transferType: String?
    var stats: [SquadStat]?
}

struct SquadStat {
    var competitionId: String?
    var competitionName: String?
    var tournamentCalendarId: String?
    var tournamentCalendarName: String?
    var goals: Int?
    var assists: Int?
    var penaltyGoals: Int?
    var appearances: Int?
    var yellowCards: Int?
    var secondYellowCards: Int?
    var redCards: Int?
    var substituteIn: Int?
    var substituteOut: Int?
    var subsOnBench: Int?
    var minutesPlayed: Int?
    var shirtNumber: Int?
    var competitionFormat: String?
    var isFriendly: String?
}

// Match Stats

struct MatchInfo {
    var id: String?
    var date: Date?
    var lastUpdated: Date?
    var description: String?
    var sport: Sport?
    var ruleSet: RuleSet?
    var competition: Competition?
    var tournamentCalendar: TournamentCalendar?
    var stage: Stage?
    var series: Series?
    var contestants: [Contestant]?
    var venue: Venue?
}

struct LiveData {
    var matchDetails: MatchDetails?
    var goals: [Goal]?
    var cards: [Card]?
    var substitutes: [Substitute]?
    var lineUps: [LineUp]?
    var matchDetailsExtra: MatchDetailsExtra?
}

struct Card {
    var contestantId: String?
    var periodId, timeMin: Int?
    var lastUpdated: Date?
    var type, playerId, playerName, optaEventId: String?
}

struct Goal {
    var contestantId: String?
    var periodId, timeMin: Int?
    var lastUpdated: Date?
    var type, scorerId, scorerName, assistPlayerId: String?
    var assistPlayerName, optaEventId: String?
    var homeScore, awayScore: Int?
}

struct LineUp {
    var contestantID: String?
    var players: [Player]?
    var teamOfficial: MatchOfficial?
    var stats: [LineUpStat]?
}

struct LineUpStat {
    var fh, sh, type, value: String?
}

struct MatchOfficial {
    var id, firstName, lastName, type: String?
}

struct Period {
    var id: Int?
    var start: Date?
    var end: Date?
    var lengthMin: Int?
    var lengthSec: Int?
}

struct Scores {
    var ht: ScoresDetail?
    var ft: ScoresDetail?
    var et: ScoresDetail?
    var pen: ScoresDetail?
    var total: ScoresDetail?
}

struct ScoresDetail {
    var home: Int?
    var away: Int?
}

struct MatchDetails {
    var matchTime: Int?
    var periodId: Int?
    var matchStatus, winner: String?
    var matchLengthMin, matchLengthSec: Int?
    var periods: [Period]?
    var scores: Scores?
}

struct MatchDetailsExtra {
    var matchOfficials: [MatchOfficial]?
}

struct Substitute {
    var contestantId: String?
    var periodId, timeMin: Int?
    var lastUpdated: Date?
    var playerOnId, playerOnName, playerOffId, playerOffName: String?
}
