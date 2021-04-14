package com.applicaster.opta.statsscreenplugin.utils

object Constants {
    // used in api that doesn't have data right now
    val OLD_CALENDAR_ID = "c5pvkmdgtsvjy0qnfuv1u9h49"
    val OLD_MATCH_ID = "8rusyp6d6l5i3puiwr0zmeu7e"

    const val PARAM_SHIELD_IMAGE_BASE_URL = "shield_image_base_url"
    const val PARAM_FLAG_IMAGE_BASE_URL = "flag_image_base_url"
    const val PARAM_PERSON_IMAGE_BASE_URL = "person_image_base_url"
    const val PARAM_SHIRT_IMAGE_BASE_URL = "shirt_image_base_url"
    const val PARAM_PARTIDOS_IMAGE_BASE_URL = "partidos_image_base_url"
    const val PARAM_TOKEN = "token"
    const val PARAM_REFERER = "referer"
    const val PARAM_COMPETITION_ID = "competition_id"
    const val PARAM_CALENDAR_ID = "calendar_id"
    const val PARAM_SHOW_TEAM = "show_team"
    const val PARAM_NUMBER_OF_MATCHES = "number_of_matches"
    const val PARAM_LOGO_URL = "logo_url"
    const val PARAM_BACK_BUTTON_URL = "back_button_url"
    const val PARAM_APP_ID = "param_app_id"
    const val PARAM_TEAMS_COUNT = "teams_count"
    const val PARAM_ENABLE_PLAYER_SCREEN = "enable_player_screen"

    // stats keys of opta
    const val FORMATION_USED = "formationUsed"

    // fallback assets
    const val DEFAULT_LOGO_URL =
            "https://assets-secure.applicaster.com/zapp/assets/app_family/148/Logo%20nav%20bar%20_%20green%20BG%20colour.jpg"
    const val DEFAULT_BACK_BUTTON_URL =
            "https://assets-secure.applicaster.com/zapp/assets/app_family/148/navbar_back_btn.png"

    // player positions
    val GOALKEEPER = "Goalkeeper"
    val MIDFIELDER = "Midfielder"
    val DEFENDER = "Defender"
    val DEFENSIVE_MIDFIELDER = "Defensive Midfielder"
    val ATTACKING_MIDFIELDER = "Attacking Midfielder"
    val ATTACKER = "Attacker"
    val SUBSTITUTE = "Substitute"
    val STRIKER = "Striker"
    val UNKNOWN = "Unknown"

    // game states
    val FIXTURE = "Fixture"
    val PLAYING = "Playing"
    val PLAYED = "Played"

    val UTC_DATE_FORMAT = "yyyy-MM-dd'Z'"
}
