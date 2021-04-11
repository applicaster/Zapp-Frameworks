//
//  NetworkURLRequestConvertible.swift
//  CopaAmericaStats
//
//  Created by Alex Zchut on 11/04/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import Foundation
import Alamofire

enum NetworkURLRequestConvertible: URLRequestConvertible {
    case matchScreen(apiToken: String, parameters: [String: AnyObject])
    case groupCards(apiToken: String, parameters: [String: AnyObject])
    case teamScreen(apiToken: String, parameters: [String: AnyObject])
    case playerScreenFullSquad(apiToken: String, parameters: [String: AnyObject])
    case playerScreenCareer(apiToken: String, parameters: [String: AnyObject])
    case allMatches(apiToken: String, parameters: [String: AnyObject])
    case allMatchesList(apiToken: String, parameters: [String: AnyObject])
    case matchDetail(apiToken: String, parameters: [String: AnyObject])
    case lineUp(apiToken: String, parameters: [String: AnyObject])
    case tournamentWinners(apiToken: String, parameters: [String: AnyObject])
    
    static let baseURL: String = "http://api.performfeeds.com/soccerdata"
    
    var method: HTTPMethod {
        switch self {
        default:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .matchScreen(let apiToken, _):
            return "/matchstats/\(apiToken)"
        case .groupCards(let apiToken, _):
            return "/standings/\(apiToken)"
        case .teamScreen(let apiToken, _):
            return "/seasonstats/\(apiToken)"
        case .playerScreenFullSquad(let apiToken, _):
            return "/squads/\(apiToken)"
        case .playerScreenCareer(let apiToken, _):
            return "/playercareer/\(apiToken)"
        case .allMatches(let apiToken, _):
            return "/tournamentschedule/\(apiToken)"
        case .allMatchesList(let apiToken, _):
            return "/match/\(apiToken)"
        case .matchDetail(let apiToken, _):
            return "/match/\(apiToken)"
        case .lineUp(let apiToken, _):
            return "/squads/\(apiToken)"
        case .tournamentWinners(let apiToken, _):
            return "/trophies/\(apiToken)"
        }
    }
    
    var cacheKey: String {
        switch self {
        case .matchScreen:
            return "matchstats"
        case .groupCards:
            return "standings"
        case .teamScreen:
            return "seasonstats"
        case .playerScreenFullSquad:
            return "squads"
        case .playerScreenCareer:
            return "playercareer"
        case .allMatches:
            return "tournamentschedule"
        case .allMatchesList:
            return "match"
        case .matchDetail:
            return "match_detail"
        case .lineUp:
            return "squads"
        case .tournamentWinners:
            return "trophies"
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url: URL = URL(string: "\(NetworkURLRequestConvertible.baseURL)\(path)")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        //Set-up parameters
        switch self {
        case .matchScreen(_, let params),
             .groupCards(_, let params),
             .teamScreen(_, let params),
             .playerScreenFullSquad(_, let params),
             .playerScreenCareer(_, let params),
             .allMatches(_, let params),
             .allMatchesList(_, let params),
             .matchDetail(_, let params),
             .lineUp(_, let params),
             .tournamentWinners(_, let params):
            let encodedURLRequest = try Alamofire.URLEncoding.default.encode(urlRequest, with: params)
            urlRequest = encodedURLRequest
            break
        }
        
        //Add necessary Header values
        switch self {
        default:
            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("copaamerica.com", forHTTPHeaderField: "Referer")
        }
        
        print("Making Request: \(urlRequest)")
        return urlRequest
    }
}
