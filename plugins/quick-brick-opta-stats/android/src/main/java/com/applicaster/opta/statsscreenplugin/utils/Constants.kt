package com.applicaster.opta.statsscreenplugin.utils

object Constants {
    // used in api that doesn't have data right now
    const val OLD_CALENDAR_ID = "c5pvkmdgtsvjy0qnfuv1u9h49"
    const val OLD_MATCH_ID = "8rusyp6d6l5i3puiwr0zmeu7e"

    const val PARAM_SHIELD_IMAGE_BASE_URL = "shield_image_base_url"
    const val PARAM_FLAG_IMAGE_BASE_URL = "flag_image_base_url"
    const val PARAM_PERSON_IMAGE_BASE_URL = "person_image_base_url"
    const val PARAM_SHIRT_IMAGE_BASE_URL = "shirt_image_base_url"
    const val PARAM_PARTIDOS_IMAGE_BASE_URL = "partidos_image_base_url"
    const val PARAM_IMAGE_BASE_URL = "image_base_url"
    const val PARAM_TOKEN = "token"
    const val PARAM_REFERER = "referer"
    const val PARAM_COMPETITION_ID = "competition_id"
    const val PARAM_CALENDAR_ID = "calendar_id"
    const val PARAM_SHOW_TEAM = "show_team"
    const val PARAM_NUMBER_OF_MATCHES = "number_of_matches"
    const val PARAM_LOGO_URL = "navbar_logo_image_url"
    const val PARAM_BACK_BUTTON_URL = "back_button_url"
    const val PARAM_NAV_BAR_COLOR = "navbar_bg_color"
    const val PARAM_APP_ID = "param_app_id"
    const val PARAM_TEAMS_COUNT = "teams_count"
    const val PARAM_ENABLE_PLAYER_SCREEN = "enable_player_screen"

    // stats keys of opta
    const val FORMATION_USED = "formationUsed"

    // fallback assets
    const val DEFAULT_LOGO_URL =
            "https://assets-secure.applicaster.com/zapp/assets/app_family/148/172523756576/header-logo-copa-america-2020.png"
    const val DEFAULT_BACK_BUTTON_URL =
            "https://assets-secure.applicaster.com/zapp/assets/app_family/148/navbar_back_btn.png"

    // player positions
    const val GOALKEEPER = "Goalkeeper"
    const val MIDFIELDER = "Midfielder"
    const val DEFENDER = "Defender"
    const val DEFENSIVE_MIDFIELDER = "Defensive Midfielder"
    const val ATTACKING_MIDFIELDER = "Attacking Midfielder"
    const val ATTACKER = "Attacker"
    const val SUBSTITUTE = "Substitute"
    const val STRIKER = "Striker"
    const val UNKNOWN = "Unknown"

    // game states
    const val FIXTURE = "Fixture"
    const val PLAYING = "Playing"
    const val PLAYED = "Played"

    const val UTC_DATE_FORMAT = "yyyy-MM-dd'Z'"

    // todo: make me enum
    const val PARAM_ALL_MATCHES_BANNER_POSITION = "all_matches_item"
    const val ALL_MATCHES_BANNER_POSITION_FIRST = "first"
    const val ALL_MATCHES_BANNER_POSITION_LAST = "last"
    const val ALL_MATCHES_BANNER_POSITION_HIDDEN = "hidden"

    // todo: make me enum
    const val PARAM_MAIN_SCREEN_MODE = "main_screen_type"
    const val PARAM_MAIN_SCREEN_MODE_DEFAULT = "default"
    const val PARAM_MAIN_SCREEN_MODE_KNOCKOUT = "knockout"

    const val PLUGIN_ID = "quick-brick-opta-stats"
}
