//
//  CopaAmericaStats.swift
//  CopaAmericaStats
//
//  Created by Alex Zchut on 11/04/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import ZappCore

public class CopaAmericaStats: NSObject, GeneralProviderProtocol {
    public var model: ZPPluginModel?
    public var configurationJSON: NSDictionary?

    public required init(pluginModel: ZPPluginModel) {
        model = pluginModel
        configurationJSON = model?.configurationJSON
    }

    public var providerName: String {
        return String(describing: Self.self)
    }

    public func prepareProvider(_ defaultParams: [String: Any],
                                completion: ((_ isReady: Bool) -> Void)?) {
        completion?(true)
    }

    public func disable(completion: ((Bool) -> Void)?) {
        completion?(true)
    }

    struct Params {
        static let apiToken = "api_token"
        static let referer = "referer"
        static let competitionId = "competition_id"
        static let calendarId = "calendar_id"
    }

    lazy var pluginParams: PluginParams = {
        PluginParams(apiToken: configurationJSON?[Params.apiToken] as? String ?? "",
                     referer: configurationJSON?[Params.referer] as? String ?? "",
                     competitionId: configurationJSON?[Params.competitionId] as? String,
                     calendarId: configurationJSON?[Params.calendarId] as? String)
    }()
}

struct PluginParams {
    var apiToken: String
    var referer: String
    var competitionId: String?
    var calendarId: String?
}
