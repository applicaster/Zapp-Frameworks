package com.applicaster.opta.statsscreenplugin.data.model

object PlayerSquadModel {
    data class PlayerSquad(
            val lastUpdated: String,
            val squad: List<Squad>
    )

    data class Squad(
            val competitionId: String,
            val competitionName: String,
            val contestantClubName: String,
            val contestantCode: String,
            val contestantId: String,
            val contestantName: String,
            val contestantShortName: String,
            val person: List<Person>,
            val teamType: String,
            val tournamentCalendarEndDate: String,
            val tournamentCalendarId: String,
            val tournamentCalendarStartDate: String,
            val type: String,
            val venueId: String,
            val venueName: String
    )

    data class Person(
            val active: String,
            val countryOfBirth: String,
            val countryOfBirthId: String,
            val dateOfBirth: String,
            val firstName: String,
            val foot: String,
            val height: Int,
            val id: String,
            val lastName: String,
            val matchName: String,
            val nationality: String,
            val nationalityId: String,
            val placeOfBirth: String,
            val position: String,
            val status: String,
            val type: String,
            val weight: Int,
            val shirtNumber: Int
    )
}
