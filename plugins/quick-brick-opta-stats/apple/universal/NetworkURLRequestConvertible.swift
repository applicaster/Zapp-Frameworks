//
//  NetworkURLRequestConvertible.swift
//  OptaStats
//
//  Created by Alex Zchut on 11/04/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import Foundation
import Alamofire

enum NetworkURLRequestError: Error {
    case invalidBaseUrl
}

enum NetworkURLRequestConvertible: URLRequestConvertible {
    case matchScreen(pluginParams: PluginParams, requestParams: [String: AnyObject])
    case groupCards(pluginParams: PluginParams, requestParams: [String: AnyObject])
    case teamScreen(pluginParams: PluginParams, requestParams: [String: AnyObject])
    case playerScreenFullSquad(pluginParams: PluginParams, requestParams: [String: AnyObject])
    case playerScreenCareer(pluginParams: PluginParams, requestParams: [String: AnyObject])
    case allMatches(pluginParams: PluginParams, requestParams: [String: AnyObject])
    case allMatchesList(pluginParams: PluginParams, requestParams: [String: AnyObject])
    case matchDetail(pluginParams: PluginParams, requestParams: [String: AnyObject])
    case lineUp(pluginParams: PluginParams, requestParams: [String: AnyObject])
    case tournamentWinners(pluginParams: PluginParams, requestParams: [String: AnyObject])
    
    static let baseURL: String = "http://api.performfeeds.com/soccerdata"
    
    var method: HTTPMethod {
        switch self {
        default:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .matchScreen(let pluginParams, _):
            return "/matchstats/\(pluginParams.apiToken)"
        case .groupCards(let pluginParams, _):
            return "/standings/\(pluginParams.apiToken)"
        case .teamScreen(let pluginParams, _):
            return "/seasonstats/\(pluginParams.apiToken)"
        case .playerScreenFullSquad(let pluginParams, _):
            return "/squads/\(pluginParams.apiToken)"
        case .playerScreenCareer(let pluginParams, _):
            return "/playercareer/\(pluginParams.apiToken)"
        case .allMatches(let pluginParams, _):
            return "/tournamentschedule/\(pluginParams.apiToken)"
        case .allMatchesList(let pluginParams, _):
            return "/match/\(pluginParams.apiToken)"
        case .matchDetail(let pluginParams, _):
            return "/match/\(pluginParams.apiToken)"
        case .lineUp(let pluginParams, _):
            return "/squads/\(pluginParams.apiToken)"
        case .tournamentWinners(let pluginParams, _):
            return "/trophies/\(pluginParams.apiToken)"
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
        guard let url: URL = URL(string: "\(NetworkURLRequestConvertible.baseURL)\(path)") else {
            throw NetworkURLRequestError.invalidBaseUrl
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        //Set-up parameters
        let encodedURLRequest = try Alamofire.URLEncoding.default.encode(urlRequest, with: content.requestParams)
        urlRequest = encodedURLRequest
        
        //Add necessary Header values
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(content.pluginParams.referer, forHTTPHeaderField: "Referer")
        
        print("Making Request: \(urlRequest)")
        return urlRequest
    }
    
    var content: (pluginParams: PluginParams, requestParams: [String: AnyObject]) {
        switch self {
        case .matchScreen(let pluginParams, let requestParams),
             .groupCards(let pluginParams, let requestParams),
             .teamScreen(let pluginParams, let requestParams),
             .playerScreenFullSquad(let pluginParams, let requestParams),
             .playerScreenCareer(let pluginParams, let requestParams),
             .allMatches(let pluginParams, let requestParams),
             .allMatchesList(let pluginParams, let requestParams),
             .matchDetail(let pluginParams, let requestParams),
             .lineUp(let pluginParams, let requestParams),
             .tournamentWinners(let pluginParams, let requestParams):
            return (pluginParams, requestParams)
        }
    }
}
