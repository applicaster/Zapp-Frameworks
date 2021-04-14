package com.applicaster.opta.statsscreenplugin.data.model

object PlayerCareerModel {
    data class PlayerCareer(
            val lastUpdated: String,
            val person: List<Person>
    )

    data class Person(
            val countryOfBirth: String,
            val countryOfBirthId: String,
            val dateOfBirth: String,
            val firstName: String,
            val foot: String,
            val gender: String,
            val height: String,
            val id: String,
            val lastName: String,
            val lastUpdated: String,
            val matchName: String,
            val membership: List<Membership>,
            val nationality: String,
            val nationalityId: String,
            val placeOfBirth: String,
            val position: String,
            val status: String,
            val type: String,
            val weight: String
    )

    data class Membership(
            val active: String,
            val contestantId: String,
            val contestantName: String,
            val contestantType: String,
            val endDate: String,
            val role: String,
            val startDate: String,
            val stat: List<Stat>,
            val transferType: String,
            val type: String
    )

    data class Stat(
            val appearances: Int,
            val assists: Int,
            val competitionFormat: String,
            val competitionId: String,
            val competitionName: String,
            val goals: Int,
            val isFriendly: String,
            val minutesPlayed: Int,
            val penaltyGoals: Int,
            val redCards: Int,
            val secondYellowCards: Int,
            val shirtNumber: Int,
            val subsOnBench: Int,
            val substituteIn: Int,
            val substituteOut: Int,
            val tournamentCalendarId: String,
            val tournamentCalendarName: String,
            val yellowCards: Int
    )
}