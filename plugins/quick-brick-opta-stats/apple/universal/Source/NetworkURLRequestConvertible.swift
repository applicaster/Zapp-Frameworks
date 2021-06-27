//
//  NetworkURLRequestConvertible.swift
//  OptaStats
//
//  Created by Alex Zchut on 11/04/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import Alamofire
import Foundation

enum NetworkURLRequestError: Error {
    case invalidBaseUrl
}

enum NetworkURLRequestConvertible: URLRequestConvertible {
    case matchScreen(requestParams: [String: AnyObject])
    case groupCards(requestParams: [String: AnyObject])
    case teamScreen(requestParams: [String: AnyObject])
    case teamCompetitionScreen(requestParams: [String: AnyObject])
    case playerScreenFullSquad(requestParams: [String: AnyObject])
    case playerScreenCareer(requestParams: [String: AnyObject])
    case allMatches(requestParams: [String: AnyObject])
    case allMatchesList(requestParams: [String: AnyObject])
    case matchDetail(requestParams: [String: AnyObject])
    case lineUp(requestParams: [String: AnyObject])
    case tournamentWinners(requestParams: [String: AnyObject])

    static let baseURL: String = "http://api.performfeeds.com/soccerdata"

    var method: HTTPMethod {
        switch self {
        default:
            return .get
        }
    }

    var path: String {
        let token = OptaStats.pluginParams.token
        switch self {
        case .matchScreen:
            return "/matchstats/\(token)"
        case .groupCards:
            return "/standings/\(token)"
        case .teamScreen:
            return "/seasonstats/\(token)"
        case .teamCompetitionScreen:
            return "/seasonstats/\(token)"
        case .playerScreenFullSquad:
            return "/squads/\(token)"
        case .playerScreenCareer:
            return "/playercareer/\(token)"
        case .allMatches:
            return "/tournamentschedule/\(token)"
        case .allMatchesList:
            return "/match/\(token)"
        case .matchDetail:
            return "/match/\(token)"
        case .lineUp:
            return "/squads/\(token)"
        case .tournamentWinners:
            return "/trophies/\(token)"
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
        case .teamCompetitionScreen:
            return "seasonstatsforcompetition"
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

        // Set-up parameters
        let encodedURLRequest = try Alamofire.URLEncoding.default.encode(urlRequest, with: requestParams)
        urlRequest = encodedURLRequest

        // Add necessary Header values
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(OptaStats.pluginParams.referer, forHTTPHeaderField: "Referer")

        print("Making Request: \(urlRequest)")
        return urlRequest
    }

    var requestParams: [String: AnyObject] {
        switch self {
        case let .matchScreen(requestParams), let
            .groupCards(requestParams), let
            .teamScreen(requestParams), let
            .teamCompetitionScreen(requestParams), let
            .playerScreenFullSquad(requestParams), let
            .playerScreenCareer(requestParams), let
            .allMatches(requestParams), let
            .allMatchesList(requestParams), let
            .matchDetail(requestParams), let
            .lineUp(requestParams), let
            .tournamentWinners(requestParams):
            return requestParams
        }
    }
}
