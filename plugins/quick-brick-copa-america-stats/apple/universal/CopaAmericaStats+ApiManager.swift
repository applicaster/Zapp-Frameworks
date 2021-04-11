//
//  CopaAmericaApiManager.swift
//  CopaAmericaStats
//
//  Created by Alex Zchut on 11/04/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

typealias CopaAmericaApiCompletionHandler = (_ success: Bool, _ json: JSON?) -> Void

extension CopaAmericaStats {
    //fixtureId = matchId
    func fetchMatchScreenDetails(fixtureId: String, completion: @escaping (CopaAmericaApiCompletionHandler)) {
        let params = [
            "_rt": "c",
            "_fmt": "json",
            "fx": fixtureId,
            "detailed": "yes",
            "_lcl": getLanguageCodeParam()
            ] as [String : AnyObject]
        
        NetworkService.makeRequest(.matchScreen(apiToken: apiToken, parameters: params)) { (success, json) in
            completion(success, json)
        }
    }

    func fetchGroupCards(tournamentCalendar: String, completion: @escaping (CopaAmericaApiCompletionHandler)) {
        let params = [
            "_rt": "c",
            "_fmt": "json",
            "tmcl": tournamentCalendar,
            "_lcl": getLanguageCodeParam()
            ] as [String : AnyObject]
        
        NetworkService.makeRequest(.groupCards(apiToken: apiToken, parameters: params)) { (success, json) in
            completion(success, json)
        }
    }

    func fetchTeamScreenDetails(tournamentCalendar: String, contestantId: String, completion: @escaping (CopaAmericaApiCompletionHandler)) {
        let params = [
            "_rt": "c",
            "_fmt": "json",
            "tmcl": tournamentCalendar,
            "ctst": contestantId,
            "detailed": "yes",
            "_lcl": getLanguageCodeParam()
            ] as [String : AnyObject]
        
        NetworkService.makeRequest(.teamScreen(apiToken: apiToken, parameters: params)) { (success, json) in
            completion(success, json)
        }
    }
    
    func fetchTournamentWinners(competitionId: String, completion: @escaping (CopaAmericaApiCompletionHandler)) {
        let params = [
            "_rt": "c",
            "_fmt": "json",
            "comp": competitionId,
            "_lcl": getLanguageCodeParam()
            ] as [String : AnyObject]
        
        NetworkService.makeRequest(.tournamentWinners(apiToken: apiToken, parameters: params)) { (success, json) in
            completion(success, json)
        }
    }

    func fetchPlayerScreenFullSquad(tournamentCalendar: String, contestantId: String, completion: @escaping (CopaAmericaApiCompletionHandler)) {
        let params = [
            "_rt": "c",
            "_fmt": "json",
            "tmcl": tournamentCalendar,
            "ctst": contestantId,
            "detailed": "yes",
            "_lcl": getLanguageCodeParam()
            ] as [String : AnyObject]
        
        NetworkService.makeRequest(.playerScreenFullSquad(apiToken: apiToken, parameters: params)) { (success, json) in
            completion(success, json)
        }
    }

    func fetchPlayerScreenCareer(personId: String, completion: @escaping (CopaAmericaApiCompletionHandler)) {
        let params = [
            "_rt": "c",
            "_fmt": "json",
            "prsn": personId,
            "_lcl": getLanguageCodeParam()
            ] as [String : AnyObject]
        
        NetworkService.makeRequest(.playerScreenCareer(apiToken: apiToken, parameters: params)) { (success, json) in
            completion(success, json)
        }
    }

    func fetchAllMatches(tournamentCalendar: String, completion: @escaping (CopaAmericaApiCompletionHandler)) {
        let params = [
            "_rt": "c",
            "_fmt": "json",
            //"tmcl": "c5pvkmdgtsvjy0qnfuv1u9h49",
            "tmcl": tournamentCalendar,
            "_ordSrt": "asc",
            "_pgSz": "50",
            "_pgNm": "1",
            "live": "yes",
            "_lcl": getLanguageCodeParam()
            ] as [String : AnyObject]
        
        NetworkService.makeRequest(.allMatchesList(apiToken: apiToken, parameters: params)) { (success, json) in
            completion(success, json)
        }
    }
    
    func fetchAllMatchesGrouped(tournamentCalendar: String, completion: @escaping (CopaAmericaApiCompletionHandler)) {
        let params = [
         "_rt": "c",
         "_fmt": "json",
         "tmcl": tournamentCalendar,
         "_lcl": getLanguageCodeParam()
         ] as [String : AnyObject]
        
        NetworkService.makeRequest(.allMatches(apiToken: apiToken, parameters: params)) { (success, json) in
            completion(success, json)
        }
    }

    func fetchMatchDetails(matchId: String, completion: @escaping (CopaAmericaApiCompletionHandler)) {
        let params = [
            "_rt": "c",
            "_fmt": "json",
            "fx": matchId,
            "_lcl": getLanguageCodeParam()
            ] as [String : AnyObject]
        
        NetworkService.makeRequest(.matchDetail(apiToken: apiToken, parameters: params)) { (success, json) in
            completion(success, json)
        }
    }
    
    func fetchLineUp(contestantId: String, completion: @escaping (CopaAmericaApiCompletionHandler)) {
        let params = [
            "_rt": "c",
            "_fmt": "json",
            "ctst": contestantId,
            "_lcl": getLanguageCodeParam()
            ] as [String : AnyObject]
        
        NetworkService.makeRequest(.lineUp(apiToken: apiToken, parameters: params)) { (success, json) in
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
