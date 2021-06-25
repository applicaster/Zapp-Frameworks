package com.applicaster.opta.statsscreenplugin.data.api

import com.applicaster.opta.statsscreenplugin.data.model.*
import com.applicaster.opta.statsscreenplugin.plugin.PluginDataRepository
import com.applicaster.util.AppContext
import io.reactivex.Observable
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Response
import retrofit2.Retrofit
import retrofit2.adapter.rxjava2.RxJava2CallAdapterFactory
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.GET
import retrofit2.http.Header
import retrofit2.http.Path
import retrofit2.http.Query


/**
 * To implement this class I used as reference this article
 * https://medium.com/@elye.project/kotlin-and-retrofit-2-tutorial-with-working-codes-333a4422a890
 */
interface OptaApiService {

    @GET("standings/{token}")
    fun getGroupCards(@Path("token") token: String,
                      @Header("Referer") referer: String, @Query("_rt") rt: String,
                      @Query("_fmt") format: String, @Query("tmcl") tournamentId: String,
                      @Query("_lcl") localization: String):
            Observable<Response<GroupModel.Group>>

    @GET("matchstats/{token}")
    fun getMatches(@Path("token") token: String,
                   @Header("Referer") referer: String, @Query("_rt") rt: String,
                   @Query("_fmt") format: String, @Query("fx") fixtureId: String,
                   @Query("detailed") detailed: String,
                   @Query("_lcl") localization: String):
            Observable<Response<MatchModel.Match>>

    @GET("seasonstats/{token}")
    fun getTeamStats(@Path("token") token: String,
                     @Header("Referer") referer: String, @Query("_rt") rt: String,
                     @Query("_fmt") format: String, @Query("tmcl") tournamentId: String,
                     @Query("ctst") contestantId: String,
                     @Query("detailed") detailed: String,
                     @Query("_lcl") localization: String):
            Observable<Response<TeamModel.Team>>

    // https://docs.performgroup.com/docs/data/reference/soccer/opta-sdapi-soccer-api-seasonal-stats.htm
    @GET("seasonstats/{token}")
    fun getTeamCompetitionStats(@Path("token") token: String,
                                @Header("Referer") referer: String,
                                @Query("_rt") rt: String,
                                @Query("_fmt") format: String,
                                @Query("comp") competitionId: String,
                                @Query("ctst") contestantId: String,
                                @Query("detailed") detailed: String,
                                @Query("_lcl") localization: String):
            Observable<Response<TeamModel.Team>>

    @GET("squads/{token}")
    fun getSquads(@Path("token") token: String,
                  @Header("Referer") referer: String, @Query("_rt") rt: String,
                  @Query("_fmt") format: String, @Query("tmcl") tournamentId: String,
                  @Query("ctst") contestantId: String,
                  @Query("detailed") detailed: String,
                  @Query("_lcl") localization: String):
            Observable<Response<PlayerSquadModel.PlayerSquad>>

    @GET("playercareer/{token}")
    fun getPlayerCareer(@Path("token") token: String,
                        @Header("Referer") referer: String, @Query("_rt") rt: String,
                        @Query("_fmt") format: String, @Query("prsn") personId: String,
                        @Query("_lcl") localization: String):
            Observable<PlayerCareerModel.PlayerCareer>

    @GET("tournamentschedule/{token}")
    fun getAllMatches(@Path("token") token: String,
                      @Header("Referer") referer: String, @Query("_rt") rt: String,
                      @Query("_fmt") format: String, @Query("tmcl") tournamentId: String,
                      @Query("_lcl") localization: String):
            Observable<AllMatchesModel.AllMatches>

    @GET("match/{token}")
    fun getMatchDetails(@Path("token") token: String,
                        @Header("Referer") referer: String, @Query("_rt") rt: String,
                        @Query("_fmt") format: String, @Query("fx") fixtureId: String,
                        @Query("_lcl") localization: String):
            Observable<MatchDetailsModel.FullMatchDetails>

    @GET("trophies/{token}")
    fun getTrophies(@Path("token") token: String,
                    @Header("Referer") referer: String, @Query("comp") competitionId: String,
                    @Query("_fmt") format: String, @Query("_rt") fixtureId: String,
                    @Query("_lcl") localization: String):
            Observable<TrophiesModel.Trophies>

    @GET("match/{token}")
    fun getAllMatchesWithDetails(@Path("token") token: String,
                                 @Header("Referer") referer: String, @Query("_rt") rt: String,
                                 @Query("_fmt") format: String, @Query("tmcl") tournamentId: String,
                                 @Query("live") live: String, @Query("_ordSrt") sort: String,
                                 @Query("_pgNm") pageNumber: String, @Query("_pgSz") pageSize: String,
                                 @Query("_lcl") localization: String):
            Observable<AllMatchesWithDetailsModel.AllMatchesWithDetails>

    companion object {
        private const val BASE_URL = "http://api.performfeeds.com/soccerdata/"
        fun create(): OptaApiService {
            val interceptor = HttpLoggingInterceptor()
            interceptor.level = HttpLoggingInterceptor.Level.BASIC
            val client: OkHttpClient = OkHttpClient.Builder()
                    .cache(CacheProvider.provideCache(AppContext.get()))
                    .addInterceptor(CacheProvider.ForceCacheInterceptor())
                    .addInterceptor(interceptor)
                    .addInterceptor {
                        return@addInterceptor it.proceed(it.request())
                                .newBuilder()
                                .addHeader("AppId", PluginDataRepository.INSTANCE.getAppId())
                                .build()
                    }
                    .build()

            val retrofit = Retrofit.Builder()
                    .addCallAdapterFactory(RxJava2CallAdapterFactory.create())
                    .addConverterFactory(GsonConverterFactory.create())
                    .client(client)
                    .baseUrl(BASE_URL)
                    .build()

            return retrofit.create(OptaApiService::class.java)
        }
    }


}