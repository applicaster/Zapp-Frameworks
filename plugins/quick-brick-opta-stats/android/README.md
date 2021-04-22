# Opta Stats

*Built by LATAM Team*

**Supports:** *iOS and Android*
*Current Version: 0.2.22 (Android), 1.0.52 (iOS)*

## About
The Opta Statistic Plugin is being developed primarily to show the statistics for Copa America 2019 tournament. Since Opta is the main provider for several events in LATAM we are pivoting this plugin to be a generic Opta plugin.

## URL Schemes supported
We predefined a set of screens which you can open through a URL scheme from anywhere in the application. In order to do so, we need to define a well-known URL schema. These are the proposed schemas for this integration.

### URL Scheme to open a screen
`<app_schema_id>://plugin?type=general&action=stats_open_screen&screen_id=<screen_id>&<other_data_key>=<other_data_value>`

- `<app_schema_id>` **(Required)**: Application scheme id.
- `<screen_id>` **(Required)**: A predefined `<screen_id>` from one of the following options:
  - `home_screen`
  - `match_details_screen`
  - `all_matches_screen`
  - `all_teams_screen`
  - `team_screen`
  - `player_screen`
- `<other_data_key>` **(Required for specific screens)**: To show values from a specific entity:
  - `match_id=<op_id>&push=<true_or_false>`
  - `team_id` (`team_screen` and `all_matches_screen`)
  - `player_id` (`player_screen`)

#### Match details & Push option
When opening match details screen through URL scheme, there is another key named push which indicates if the URL scheme comes from the push or if it’s being opened within the app.

When the url scheme is coming from push the `match_id` is different from the one provided by Opta. Let's call this data, `match_id_from_push`. The match id from the push must be sent to the Opta API as `match_id`, `urn:perform:opta:fixture:<match_id_from_push>`. The id coming from the push may have a letter at the beginning. It is necessary to remove this letter to use it as `match_id` in the API call.

## Available screens
The list of screen available in the integration will be the following:
- [Home screen](#home-screen)
- [Match Details Screen](#match-details-screen)
- [All Matches Screen](#all-matches-screen)
- [Team Screen](#team-screen)
- [Player Screen](#player-screen)

### <a name=home-screen></a> Home screen
You can find the whole design [here](https://app.zeplin.io/project/5c8863d4039b9f39096d453d/screen/5c8864178bd661197ccb8c82).

![Home screen preview](https://github.com/applicaster/latam-product-documentation/blob/master/Opta-Stats/media/home_screen.png)

### <a name=match-details-screen></a> Match Details Screen
You can find the complete design [here](https://app.zeplin.io/project/5c8863d4039b9f39096d453d/screen/5c88641af85b69045c2eafca).

![Match details screen preview](https://github.com/applicaster/latam-product-documentation/blob/master/Opta-Stats/media/match_details_1.png) ![Match details screen preview](https://github.com/applicaster/latam-product-documentation/blob/master/Opta-Stats/media/match_details_2.png) ![Match details screen preview](https://github.com/applicaster/latam-product-documentation/blob/master/Opta-Stats/media/match_details_3.png)

### <a name=all-matches-screen></a> All Matches Screen
You can find the complete design [here](https://app.zeplin.io/project/5c8863d4039b9f39096d453d/screen/5c886418988ef419824d583b).

![All matches screen preview](https://github.com/applicaster/latam-product-documentation/blob/master/Opta-Stats/media/all_matches_screen.png)

### <a name=team-screen></a> Team Screen
You can find the complete design [here](https://app.zeplin.io/project/5c8863d4039b9f39096d453d/screen/5caf607f225f00a04b00e1d2).

![Team screen preview](https://github.com/applicaster/latam-product-documentation/blob/master/Opta-Stats/media/team_screen.png)

### <a name=player-screen></a> Player Screen
You can find the complete design [here](https://app.zeplin.io/project/5c8863d4039b9f39096d453d/screen/5cab7ce9e89d3f338980bcb3).

![Player screen preview](https://github.com/applicaster/latam-product-documentation/blob/master/Opta-Stats/media/player_screen.png)

## Plugin configuration
In order to make this plugin generic and be used for other tournaments, we defined the following parameters:

`token`: Token to access the information provided by Opta
`referer`: Domain(s) the client provided to Opta to allow access to its API’s
`competition_id`: Competition id of the tournament
`calendar_id`: Calendar id of the tournament
`image_base_url`: URL where the plugin get the images
`show_team`: Parameter to show rooster or not, in case the client doesn’t want to show the rooster yet.
`number_of_matches`: Number of matches that will be shown in the home carousel.

### How to configure the plugin
In Zapp Builder, go to the screen plugin, and in the right panel, you will see the fields to be filled.

![Stats configuration](https://github.com/applicaster/latam-product-documentation/blob/master/Opta-Stats/media/stats_configuration.png)