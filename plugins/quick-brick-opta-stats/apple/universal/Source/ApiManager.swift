//
//  ApiManager.swift
//  OptaStats
//
//  Created by Alex Zchut on 11/04/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import Alamofire
import SwiftyJSON
import UIKit

typealias ApiCompletionHandler = (_ success: Bool, _ content: JSON?) -> Void

struct ApiManager {
    static func fetchMatchScreenDetails(fixtureId: String,
                                        completion: @escaping (ApiCompletionHandler)) {
        let params = [
            "_rt": "c",
            "_fmt": "json",
            "fx": fixtureId,
            "detailed": "yes",
            "_lcl": getLanguageCodeParam(),
        ] as [String: AnyObject]

        NetworkService.makeRequest(.matchScreen(requestParams: params)) { success, json in
            completion(success, json)
        }
    }

    static func fetchGroupCards(tournamentCalendar: String,
                                completion: @escaping (ApiCompletionHandler)) {
        let params = [
            "_rt": "c",
            "_fmt": "json",
            "tmcl": tournamentCalendar,
            "_lcl": getLanguageCodeParam(),
        ] as [String: AnyObject]

        NetworkService.makeRequest(.groupCards(requestParams: params)) { success, json in
            completion(success, json)
        }
    }

    static func fetchTeamScreenDetails(tournamentCalendar: String,
                                       contestantId: String,
                                       completion: @escaping (ApiCompletionHandler)) {
        let params = [
            "_rt": "c",
            "_fmt": "json",
            "tmcl": tournamentCalendar,
            "ctst": contestantId,
            "detailed": "yes",
            "_lcl": getLanguageCodeParam(),
        ] as [String: AnyObject]

        NetworkService.makeRequest(.teamScreen(requestParams: params)) { success, json in
            completion(success, json)
        }
    }

    static func fetchTournamentWinners(competitionId: String,
                                       completion: @escaping (ApiCompletionHandler)) {
        let params = [
            "_rt": "c",
            "_fmt": "json",
            "comp": competitionId,
            "_lcl": getLanguageCodeParam(),
        ] as [String: AnyObject]

        NetworkService.makeRequest(.tournamentWinners(requestParams: params)) { success, json in
            completion(success, json)
        }
    }

    static func fetchPlayerScreenFullSquad(tournamentCalendar: String,
                                           contestantId: String,
                                           completion: @escaping (ApiCompletionHandler)) {
        let params = [
            "_rt": "c",
            "_fmt": "json",
            "tmcl": tournamentCalendar,
            "ctst": contestantId,
            "detailed": "yes",
            "_lcl": getLanguageCodeParam(),
        ] as [String: AnyObject]

        NetworkService.makeRequest(.playerScreenFullSquad(requestParams: params)) { success, json in
            completion(success, json)
        }
    }

    static func fetchPlayerScreenCareer(personId: String,
                                        completion: @escaping (ApiCompletionHandler)) {
        let params = [
            "_rt": "c",
            "_fmt": "json",
            "prsn": personId,
            "_lcl": getLanguageCodeParam(),
        ] as [String: AnyObject]

        NetworkService.makeRequest(.playerScreenCareer(requestParams: params)) { success, json in
            completion(success, json)
        }
    }

    static func fetchAllMatches(tournamentCalendar: String,
                                completion: @escaping (ApiCompletionHandler)) {
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

        NetworkService.makeRequest(.allMatchesList(requestParams: params)) { success, json in
            completion(success, json)
        }
    }

    static func fetchAllMatchesGrouped(tournamentCalendar: String,
                                       completion: @escaping (ApiCompletionHandler)) {
        let params = [
            "_rt": "c",
            "_fmt": "json",
            "tmcl": tournamentCalendar,
            "_lcl": getLanguageCodeParam(),
        ] as [String: AnyObject]

        NetworkService.makeRequest(.allMatches(requestParams: params)) { success, json in
            completion(success, json)
        }
    }

    static func fetchMatchDetails(matchId: String,
                                  completion: @escaping (ApiCompletionHandler)) {
        let params = [
            "_rt": "c",
            "_fmt": "json",
            "fx": matchId,
            "_lcl": getLanguageCodeParam(),
        ] as [String: AnyObject]

        NetworkService.makeRequest(.matchDetail(requestParams: params)) { success, json in
            completion(success, json)
        }
    }

    static func fetchLineUp(contestantId: String,
                            completion: @escaping (ApiCompletionHandler)) {
        let params = [
            "_rt": "c",
            "_fmt": "json",
            "ctst": contestantId,
            "_lcl": getLanguageCodeParam(),
        ] as [String: AnyObject]

        NetworkService.makeRequest(.lineUp(requestParams: params)) { success, json in
            completion(success, json)
        }
    }

    static func getLanguageCodeParam() -> String {
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