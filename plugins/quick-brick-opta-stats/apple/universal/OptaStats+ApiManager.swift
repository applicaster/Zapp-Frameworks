//
//  OptaStats+ApiManager.swift
//  OptaStats
//
//  Created by Alex Zchut on 11/04/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import Alamofire
import SwiftyJSON
import UIKit

typealias OptaApiCompletionHandler = (_ success: Bool, _ json: JSON?) -> Void

extension OptaStats {
    func fetchMatchScreenDetails(fixtureId: String,
                                 completion: @escaping (OptaApiCompletionHandler)) {
        let params = [
            "_rt": "c",
            "_fmt": "json",
            "fx": fixtureId,
            "detailed": "yes",
            "_lcl": getLanguageCodeParam(),
        ] as [String: AnyObject]

        NetworkService.makeRequest(.matchScreen(pluginParams: pluginParams,
                                                requestParams: params)) { success, json in
            completion(success, json)
        }
    }

    func fetchGroupCards(tournamentCalendar: String,
                         completion: @escaping (OptaApiCompletionHandler)) {
        let params = [
            "_rt": "c",
            "_fmt": "json",
            "tmcl": tournamentCalendar,
            "_lcl": getLanguageCodeParam(),
        ] as [String: AnyObject]

        NetworkService.makeRequest(.groupCards(pluginParams: pluginParams,
                                               requestParams: params)) { success, json in
            completion(success, json)
        }
    }

    func fetchTeamScreenDetails(tournamentCalendar: String,
                                contestantId: String,
                                completion: @escaping (OptaApiCompletionHandler)) {
        let params = [
            "_rt": "c",
            "_fmt": "json",
            "tmcl": tournamentCalendar,
            "ctst": contestantId,
            "detailed": "yes",
            "_lcl": getLanguageCodeParam(),
        ] as [String: AnyObject]

        NetworkService.makeRequest(.teamScreen(pluginParams: pluginParams,
                                               requestParams: params)) { success, json in
            completion(success, json)
        }
    }

    func fetchTournamentWinners(competitionId: String,
                                completion: @escaping (OptaApiCompletionHandler)) {
        let params = [
            "_rt": "c",
            "_fmt": "json",
            "comp": competitionId,
            "_lcl": getLanguageCodeParam(),
        ] as [String: AnyObject]

        NetworkService.makeRequest(.tournamentWinners(pluginParams: pluginParams,
                                                      requestParams: params)) { success, json in
            completion(success, json)
        }
    }

    func fetchPlayerScreenFullSquad(tournamentCalendar: String,
                                    contestantId: String,
                                    completion: @escaping (OptaApiCompletionHandler)) {
        let params = [
            "_rt": "c",
            "_fmt": "json",
            "tmcl": tournamentCalendar,
            "ctst": contestantId,
            "detailed": "yes",
            "_lcl": getLanguageCodeParam(),
        ] as [String: AnyObject]

        NetworkService.makeRequest(.playerScreenFullSquad(pluginParams: pluginParams,
                                                          requestParams: params)) { success, json in
            completion(success, json)
        }
    }

    func fetchPlayerScreenCareer(personId: String,
                                 completion: @escaping (OptaApiCompletionHandler)) {
        let params = [
            "_rt": "c",
            "_fmt": "json",
            "prsn": personId,
            "_lcl": getLanguageCodeParam(),
        ] as [String: AnyObject]

        NetworkService.makeRequest(.playerScreenCareer(pluginParams: pluginParams,
                                                       requestParams: params)) { success, json in
            completion(success, json)
        }
    }

    func fetchAllMatches(tournamentCalendar: String,
                         completion: @escaping (OptaApiCompletionHandler)) {
        let params = [
            "_rt": "c",
            "_fmt": "json",
            "tmcl": tournamentCalendar,
            "_ordSrt": "asc",
            "_pgSz": "50",
            "_pgNm": "1",
            "live": "yes",
            "_lcl": getLanguageCodeParam(),
        ] as [String: AnyObject]

        NetworkService.makeRequest(.allMatchesList(pluginParams: pluginParams,
                                                   requestParams: params)) { success, json in
            completion(success, json)
        }
    }

    func fetchAllMatchesGrouped(tournamentCalendar: String,
                                completion: @escaping (OptaApiCompletionHandler)) {
        let params = [
            "_rt": "c",
            "_fmt": "json",
            "tmcl": tournamentCalendar,
            "_lcl": getLanguageCodeParam(),
        ] as [String: AnyObject]

        NetworkService.makeRequest(.allMatches(pluginParams: pluginParams,
                                               requestParams: params)) { success, json in
            completion(success, json)
        }
    }

    func fetchMatchDetails(matchId: String,
                           completion: @escaping (OptaApiCompletionHandler)) {
        let params = [
            "_rt": "c",
            "_fmt": "json",
            "fx": matchId,
            "_lcl": getLanguageCodeParam(),
        ] as [String: AnyObject]

        NetworkService.makeRequest(.matchDetail(pluginParams: pluginParams,
                                                requestParams: params)) { success, json in
            completion(success, json)
        }
    }

    func fetchLineUp(contestantId: String,
                     completion: @escaping (OptaApiCompletionHandler)) {
        let params = [
            "_rt": "c",
            "_fmt": "json",
            "ctst": contestantId,
            "_lcl": getLanguageCodeParam(),
        ] as [String: AnyObject]

        NetworkService.makeRequest(.lineUp(pluginParams: pluginParams,
                                           requestParams: params)) { success, json in
            completion(success, json)
        }
    }

    func getLanguageCodeParam() -> String {
        let deviceLocale = NSLocale.current.languageCode

        switch deviceLocale {
        case "en":
            return "en-en"
        case "es":
            return "es-es"
        case "pt":
            return "pt-br"
        default:
            return "es-es"
        }
    }
}
