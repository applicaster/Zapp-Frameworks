package com.applicaster.opta.statsscreenplugin.screens.matchdetails

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.applicaster.opta.statsscreenplugin.OptaStatsActivity.Companion.MATCH_ID
import com.applicaster.opta.statsscreenplugin.OptaStatsActivity.Companion.PUSH
import com.applicaster.opta.statsscreenplugin.OptaStatsActivity.Companion.TRUE
import com.applicaster.opta.statsscreenplugin.R
import com.applicaster.opta.statsscreenplugin.data.model.MatchModel
import com.applicaster.opta.statsscreenplugin.screens.base.HeartbeatFragment
import com.applicaster.opta.statsscreenplugin.screens.matchdetails.adapter.PlayerGoalAdapter
import com.applicaster.opta.statsscreenplugin.screens.matchdetails.adapter.PlayerPosition
import com.applicaster.opta.statsscreenplugin.screens.matchdetails.adapter.PlayerPositionAdapter
import com.applicaster.opta.statsscreenplugin.screens.matchdetails.adapter.PlayerTeamAdapter
import com.applicaster.opta.statsscreenplugin.utils.Constants.FORMATION_USED
import com.applicaster.opta.statsscreenplugin.utils.ModelUtils
import com.applicaster.opta.statsscreenplugin.utils.PluginUtils
import com.applicaster.opta.statsscreenplugin.utils.UrlType
import com.squareup.picasso.Picasso
import kotlinx.android.synthetic.main.fragment_match_details.*

class MatchDetailsFragment : HeartbeatFragment(), MatchDetailsView {

    var matchDetailsPresenter: MatchDetailsPresenter = MatchDetailsPresenter(this, MatchDetailsInteractor())

    lateinit var matchId: String

    companion object {
        fun newInstance(matchId: String, push: String?): Fragment {
            val args = Bundle()
            args.putString(MATCH_ID, matchId)
            push?.let {
                args.putString(PUSH, push)
            }
            val fragment = MatchDetailsFragment()
            fragment.arguments = args
            return fragment
        }
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.fragment_match_details, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        matchId = arguments?.get(MATCH_ID).toString()
        arguments?.get(PUSH)?.let {
            if (it == TRUE) {
                val regex = "[^\\d]".toRegex()
                val exclude = regex.find(matchId)?.value.toString()
                matchId = matchId.replace(exclude, "")
                matchId = String.format("urn:perform:opta:fixture:%s", matchId)
            }
        }
        matchDetailsPresenter.getMatchDetails(matchId)
    }

    override fun heartbeat() {
        matchDetailsPresenter.getMatchDetails(matchId)
    }

    override fun getMatchDetailsSuccess(matchDetails: MatchModel.Match) {
        // first part of the screen
        setUpMatchBasicData(matchDetails)

        // player goals
        setUpPlayerGoals(matchDetails.liveData?.goal, matchDetails.matchInfo?.contestant!![0].id)

        // statistics
        setUpStatistics(matchDetails.liveData!!)

        // formation map
        setUpFormation(matchDetails)

        setUpTeams(matchDetails)
    }

    private fun setUpTeams(matchDetails: MatchModel.Match) {
        val liveData = matchDetails.liveData

        liveData?.lineUp?.let {
            tv_formation_home_title.text = ModelUtils.formatFormation(ModelUtils.getMatchStatistic(it[0].stat,
                    FORMATION_USED))
            tv_formation_away_title.text = ModelUtils.formatFormation(ModelUtils.getMatchStatistic(it[1].stat,
                    FORMATION_USED))

            val listOfPlayersHomeTeam = ModelUtils.getFieldPlayers(it[0].player)
            rv_home_team.layoutManager = LinearLayoutManager(context)
            rv_home_team.adapter = PlayerTeamAdapter(listOfPlayersHomeTeam, context, true)

            val listOfPlayersAwayTeam = ModelUtils.getFieldPlayers(it[1].player)
            rv_away_team.layoutManager = LinearLayoutManager(context)
            rv_away_team.adapter = PlayerTeamAdapter(listOfPlayersAwayTeam, context, false)

            val listOfReservesHomeTeam = ModelUtils.getReservePlayers(it[0].player)
            rv_reserves_home.layoutManager = LinearLayoutManager(context)
            rv_reserves_home.adapter = PlayerTeamAdapter(listOfReservesHomeTeam, context, true)

            val listOfReservesAwayTeam = ModelUtils.getReservePlayers(it[1].player)
            rv_reserves_away.layoutManager = LinearLayoutManager(context)
            rv_reserves_away.adapter = PlayerTeamAdapter(listOfReservesAwayTeam, context, false)

            tv_home_coach_name.text = it[0].teamOfficial.lastName
            tv_away_coach_name.text = it[1].teamOfficial.lastName
        }

        liveData?.matchDetailsExtra?.let {
            tv_principal_referee_name.text = it.matchOfficial[0].firstName
            tv_principal_asistant_name_1.text = it.matchOfficial[1].firstName
            tv_principal_asistant_name_2.text = it.matchOfficial[2].firstName
        }

    }

    private fun setUpStatistics(liveData: MatchModel.LiveData) {
        // region possession
        val homePossessionNumber = ModelUtils.getMatchStatistic(liveData.lineUp!![0].stat,
                "possessionPercentage")?.toFloat()
        val homePossession = homePossessionNumber?.toInt().toString() + "%"
        tv_possession_home.text = homePossession
        pb_possession_home.max = 100
        pb_possession_home.progress = homePossessionNumber!!.toInt()

        val awayPossessionNumber = ModelUtils.getMatchStatistic(liveData.lineUp!![1].stat,
                "possessionPercentage")?.toFloat()
        val awayPossession = awayPossessionNumber?.toInt().toString() + "%"
        tv_possession_away.text = awayPossession
        pb_possession_away.max = 100
        pb_possession_away.progress = awayPossessionNumber!!.toInt()
        // endregion

        // region accurate passes
        val homeAccuratePassesNumber = ModelUtils.getMatchStatistic(liveData.lineUp!![0].stat,
                "accuratePass")?.toFloat()
        val homeTotalPassesNumber = ModelUtils.getMatchStatistic(liveData.lineUp!![0].stat,
                "totalPass")?.toFloat()
        val homeAccuratePassesPercentage = homeAccuratePassesNumber?.times(100)?.div(homeTotalPassesNumber!!)
        val homeAccuratePassesString = homeAccuratePassesPercentage?.toInt().toString() + "%"
        tv_completed_passes_home.text = homeAccuratePassesString
        pb_completed_passes_home.max = homeTotalPassesNumber!!.toInt()
        pb_completed_passes_home.progress = homeAccuratePassesNumber!!.toInt()

        val awayAccuratePassesNumber = ModelUtils.getMatchStatistic(liveData.lineUp!![1].stat,
                "accuratePass")?.toFloat()
        val awayTotalPassesNumber = ModelUtils.getMatchStatistic(liveData.lineUp!![1].stat,
                "totalPass")?.toFloat()
        val awayAccuratePassesPercentage = awayAccuratePassesNumber?.times(100)?.div(awayTotalPassesNumber!!)
        val awayAccuratePassesString = awayAccuratePassesPercentage?.toInt().toString() + "%"
        tv_completed_passes_away.text = awayAccuratePassesString
        pb_completed_passes_away.max = awayTotalPassesNumber!!.toInt()
        pb_completed_passes_away.progress = awayAccuratePassesNumber!!.toInt()
        // endregion

        // region corners
        tv_corner_value_home.text = ModelUtils.getMatchStatistic(liveData.lineUp!![0].stat,
                "wonCorners")
        tv_corner_value_away.text = ModelUtils.getMatchStatistic(liveData.lineUp!![1].stat,
                "wonCorners")
        // endregion

        // region shot to goal
        val homeShotToGoalNumber = ModelUtils.getMatchStatistic(liveData.lineUp!![0].stat,
                "shotOffTarget")?.toFloat()
        val homeShotToGoalTotalNumber = ModelUtils.getMatchStatistic(liveData.lineUp!![0].stat,
                "totalScoringAtt")?.toFloat()
        val homeShotToGoalPercentage = homeShotToGoalNumber?.times(100)?.div(homeShotToGoalTotalNumber!!)
        val homeShotToGoalString = homeShotToGoalPercentage?.toInt().toString() + "%"
        tv_shot_to_goal_home.text = homeShotToGoalString
        pb_shot_to_goal_home.max = homeShotToGoalTotalNumber!!.toInt()
        pb_shot_to_goal_home.progress = homeShotToGoalNumber!!.toInt()

        val awayShotToGoalNumber = ModelUtils.getMatchStatistic(liveData.lineUp!![1].stat,
                "shotOffTarget")?.toFloat()
        val awayShotToGoalTotalNumber = ModelUtils.getMatchStatistic(liveData.lineUp!![1].stat,
                "totalScoringAtt")?.toFloat()
        val awayShotToGoalPercentage = awayShotToGoalNumber?.times(100)?.div(awayShotToGoalTotalNumber!!)
        val awayShotToGoalString = awayShotToGoalPercentage?.toInt().toString() + "%"
        tv_shot_to_goal_away.text = awayShotToGoalString
        pb_shot_to_goal_away.max = awayShotToGoalTotalNumber!!.toInt()
        pb_shot_to_goal_away.progress = awayShotToGoalNumber!!.toInt()
        // endregion

        // region cards
        tv_fault_value_home.text = ModelUtils.getMatchStatistic(liveData.lineUp!![0].stat,
                "totalTackle")
        tv_home_yellow_cards_value.text = ModelUtils.getMatchStatistic(liveData.lineUp!![0].stat,
                "totalYellowCard")
        tv_home_red_cards_value.text = ModelUtils.getMatchStatistic(liveData.lineUp!![0].stat,
                "totalRedCard")
        tv_fault_value_away.text = ModelUtils.getMatchStatistic(liveData.lineUp!![1].stat,
                "totalTackle")
        tv_away_yellow_cards_value.text = ModelUtils.getMatchStatistic(liveData.lineUp!![1].stat,
                "totalYellowCard")
        tv_away_red_cards_value.text = ModelUtils.getMatchStatistic(liveData.lineUp!![1].stat,
                "totalRedCard")
        // endregion
    }

    private fun setUpPlayerGoals(goal: List<MatchModel.Goal>?, homeContestantId: String) {
        rv_goals.layoutManager = LinearLayoutManager(context)
        goal?.let {
            rv_goals.adapter = PlayerGoalAdapter(goal, context, homeContestantId)
        } ?: run {
            rv_goals.adapter = PlayerGoalAdapter(ArrayList(), context, homeContestantId)
        }
    }

    // todo: clean up
    private fun setUpMatchBasicData(matchDetails: MatchModel.Match) {
        val matchInfo = matchDetails.matchInfo!!
        val liveData = matchDetails.liveData!!

        matchInfo.contestant?.get(0)?.id?.let { Picasso.get().load(ModelUtils.getImageUrl(UrlType.Flag, it)).placeholder(R.drawable.unknow_flag).into(iv_flag_1) }
        matchInfo.contestant?.get(1)?.id?.let { Picasso.get().load(ModelUtils.getImageUrl(UrlType.Flag, it)).placeholder(R.drawable.unknow_flag).into(iv_flag_2) }

        iv_flag_1.setOnClickListener { PluginUtils.goToTeamScreen(matchInfo.contestant!![0].id) }
        iv_flag_2.setOnClickListener { PluginUtils.goToTeamScreen(matchInfo.contestant!![1].id) }

        tv_date.text = ModelUtils.getReadableDateFromString(String.format("%s%s", matchInfo.date, matchInfo.time)).toUpperCase()
        tv_phase.text = matchInfo.stage.name.toUpperCase()
        tv_location.text = matchInfo.venue?.shortName?.toUpperCase()

        tv_country_1.text = matchInfo.contestant!![0].code
        tv_country_2.text = matchInfo.contestant!![1].code

        tv_goals_1.text = liveData.matchDetails.scores?.total?.home.toString()
        tv_goals_2.text = liveData.matchDetails.scores?.total?.away.toString()

        if (tv_goals_1.text == "null") tv_goals_1.text = "-"
        if (tv_goals_2.text == "null") tv_goals_2.text = "-"

        liveData.matchDetails.scores?.pen?.let {
            if (liveData.matchDetails.scores?.et != null) {
                tv_goals_1.text = liveData.matchDetails.scores?.et?.home.toString()
                tv_goals_2.text = liveData.matchDetails.scores?.et?.away.toString()
            } else {
                tv_goals_1.text = liveData.matchDetails.scores?.ft?.home.toString()
                tv_goals_2.text = liveData.matchDetails.scores?.ft?.away.toString()
            }

            tv_penalties.visibility = View.VISIBLE
            tv_penalties_home.visibility = View.VISIBLE
            tv_penalties_away.visibility = View.VISIBLE
            tv_penalties_home.text = liveData.matchDetails.scores?.pen?.home.toString()
            tv_penalties_away.text = liveData.matchDetails.scores?.pen?.away.toString()
        }

        tv_game_state.text = ModelUtils.getGameState(context, liveData.matchDetails.matchStatus)

        tv_time.text = "-"

        liveData.matchDetails.matchTime?.let {
            tv_time.text = String.format("%s\'", it)
            pb_gam_state.max = 90
            pb_gam_state.progress = it
        } ?: run {
            if (liveData.matchDetails.period != null &&
                    liveData.matchDetails.period!!.size == 1) {
                tv_time.text = resources.getString(R.string.half_time)
            } else {
                liveData.matchDetails.matchLengthMin?.let {
                    pb_gam_state.max = 90
                    pb_gam_state.progress = it
                    tv_time.text = String.format("%d\'", it)
                }
            }
        }

    }

    private fun setUpFormation(matchDetails: MatchModel.Match) {
        val lineUpContestant1 =
                ModelUtils.getLineUpFromContestant(matchDetails.liveData,
                        true)
        val lineUpContestant2 =
                ModelUtils.getLineUpFromContestant(matchDetails.liveData,
                        false)

        if (lineUpContestant1 != null) {
            setUpFormationFromLineUp(lineUpContestant1, rv1, rv2, rv3, rv4, rv5, true)
        }

        if (lineUpContestant2 != null) {
            setUpFormationFromLineUp(lineUpContestant2, lv1, lv2, lv3, lv4, lv5, false)
        }
    }

    private fun setUpFormationFromLineUp(lineUpContestant: MatchModel.LineUp,
                                         line1: RecyclerView,
                                         line2: RecyclerView,
                                         line3: RecyclerView,
                                         line4: RecyclerView,
                                         line5: RecyclerView,
                                         isHomeTeam: Boolean) {
        // to get the formation used for the team we need to look for the statistic with name "formationUsed"
        // in the lineUp object (look for ModelUtils.getMatchStatistic for more info)
        val formationUsed = ModelUtils.getMatchStatistic(lineUpContestant.stat, "formationUsed")

        // counter of the number of players in each line
        // line 1 is ignored because always is 1 (goal keeper line)
        var line2Counter = 0
        var line3Counter = 0
        var line4Counter = 0
        var line5Counter = 0

        // the formation used comes in the format of a string (for example: "3521")
        // so this loop will assign each number line to the correspondent counter
        if (formationUsed != null) {
            for (number in 1..formationUsed.length) {
                when (number) {
                    1 -> line2Counter = formationUsed.substring(0, 1).toInt()
                    2 -> line3Counter = formationUsed.substring(1, 2).toInt()
                    3 -> line4Counter = formationUsed.substring(2, 3).toInt()
                    4 -> line5Counter = formationUsed.substring(3, 4).toInt()
                }
            }
        }

        // get the shirt number of the correspondent formation place
        val shirtNumbers: HashMap<Int, String> = HashMap()
        // to get the formation place of the player see ModelUtils.getShirtNumber
        for (i in 0..10) {
            shirtNumbers[i] = ModelUtils.getShirtNumberOf(i + 1, lineUpContestant)
        }
        // this formationCounter is created to access the values of shirtNumber
        // every time a value is assigned, the counter increments
        var formationCounter = 0

        // goal keeper
        val players =
                listOf(PlayerPosition(shirtNumbers[formationCounter]!!, isHomeTeam))
        formationCounter++

        // creating the arrays to assign each array to the correspondent recycler view
        val line2Players = ArrayList<PlayerPosition>()
        val line3Players = ArrayList<PlayerPosition>()
        val line4Players = ArrayList<PlayerPosition>()
        val line5Players = ArrayList<PlayerPosition>()

        for (i in 1..line2Counter) {
            line2Players.add(PlayerPosition(shirtNumbers[formationCounter]!!, isHomeTeam))
            formationCounter++
        }

        for (i in 1..line3Counter) {
            line3Players.add(PlayerPosition(shirtNumbers[formationCounter]!!, isHomeTeam))
            formationCounter++
        }

        for (i in 1..line4Counter) {
            line4Players.add(PlayerPosition(shirtNumbers[formationCounter]!!, isHomeTeam))
            formationCounter++
        }

        if (line5Counter != 0) {
            for (i in 1..line5Counter) {
                line5Players.add(PlayerPosition(shirtNumbers[formationCounter]!!, isHomeTeam))
                formationCounter++
            }
        } else {
            line5.visibility = View.GONE
        }

        line1.layoutManager = LinearLayoutManager(context)
        line1.adapter = PlayerPositionAdapter(players, context)

        line2.layoutManager = LinearLayoutManager(context)
        line2.adapter = PlayerPositionAdapter(line2Players, context)

        line3.layoutManager = LinearLayoutManager(context)
        line3.adapter = PlayerPositionAdapter(line3Players, context)

        line4.layoutManager = LinearLayoutManager(context)
        line4.adapter = PlayerPositionAdapter(line4Players, context)

        line5.layoutManager = LinearLayoutManager(context)
        line5.adapter = PlayerPositionAdapter(line5Players, context)
    }

    override fun getMatchDetailsFail(error: String?) {
        // todo: implement this method
    }

    override fun showProgress() {// todo: implement this method
    }

    override fun hideProgress() {// todo: implement this method
    }

    override fun onDestroy() {
        super.onDestroy()
        matchDetailsPresenter.onDestroy()
    }
}