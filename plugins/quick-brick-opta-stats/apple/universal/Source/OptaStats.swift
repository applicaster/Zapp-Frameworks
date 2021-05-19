//
//  OptaStats.swift
//  OptaStats
//
//  Created by Alex Zchut on 11/04/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import ZappCore

public class OptaStats: NSObject, GeneralProviderProtocol {
    public static var pluginParams: PluginParams = PluginParams()

    public var model: ZPPluginModel?
    public var configurationJSON: NSDictionary?

    var targetView: UIView?
    var currentChildViewController: UIViewController?
    var currentPresentedViewController: UIViewController?
    
    public required init(pluginModel: ZPPluginModel) {
        model = pluginModel
        configurationJSON = model?.object["configuration_json"] as? NSDictionary
    }

    public var providerName: String {
        return String(describing: Self.self)
    }

    public func prepareProvider(_ defaultParams: [String: Any],
                                completion: ((_ isReady: Bool) -> Void)?) {
        updateParams()
        // TODO: urlsheme handler initialization
        completion?(true)
    }

    public func disable(completion: ((Bool) -> Void)?) {
        completion?(true)
    }

    struct Params {
        static let token = "token"
        static let referer = "referer"
        static let competitionId = "competition_id"
        static let calendarId = "calendar_id"
        static let imageBaseUrl = "image_base_url"
        static let showTeam = "show_team"
        static let numberOfMatches = "number_of_matches"
        static let navbarBgColor = "navbar_bg_color"
        static let navbarLogoImageUrl = "navbar_logo_image_url"
    }

    lazy var pluginParams: PluginParams = {
        PluginParams(token: configurationJSON?[Params.token] as? String ?? "",
                     referer: configurationJSON?[Params.referer] as? String ?? "",
                     competitionId: configurationJSON?[Params.competitionId] as? String ?? "",
                     calendarId: configurationJSON?[Params.calendarId] as? String ?? "",
                     imageBaseUrl: configurationJSON?[Params.imageBaseUrl] as? String ?? "",
                     showTeam: configurationJSON?[Params.showTeam] as? String ?? "false",
                     numberOfMatches: configurationJSON?[Params.numberOfMatches] as? String ?? "3",
                     navbarBgColor: configurationJSON?[Params.navbarBgColor] as? String ?? "",
                     navbarLogoImageUrl: configurationJSON?[Params.navbarLogoImageUrl] as? String ?? "")
    }()

    public lazy var mainStoryboard: UIStoryboard = {
        UIStoryboard(name: "StatsViewControllers", bundle: Bundle(for: self.classForCoder))
    }()

    func updateParams() {
        OptaStats.pluginParams = pluginParams
    }

    func showScreen(on targetView: UIView) {
        self.targetView = targetView

        guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: "GroupCardsViewController") as? GroupCardsViewController else {
            return
        }
        
        let viewModel = GroupCardsViewModel()
        viewController.groupCardViewModel = viewModel
        replaceViewController(with: viewController, on: nil)
    }
    
    func showScreen(with screenArguments: NSDictionary, completion: ((_ success: Bool) -> Void)?) {
        guard let screenArguments = screenArguments as? [String: Any] else {
            return
        }
        
        let targetViewController = UIApplication.shared.keyWindow?.rootViewController
        let success = handlePresentScreen(targetViewController: targetViewController, screenArguments: screenArguments)
        
        completion?(success)
    }
}

enum StatsScreenType: String {
    case undefined = "home_screen"
    case groupScreen = "groups"
    case teamsScreen = "all_teams_screen"
    case teamScreen = "team_screen"
    case matchesScreen = "all_matches_screen"
    case matchScreen = "match_details_screen"
    case playerScreen = "player_screen"
}

public struct PluginParams {
    var token: String
    var referer: String
    var competitionId: String
    var calendarId: String
    var imageBaseUrl: String
    var showTeam: Bool
    var numberOfMatches: Int
    var navbarBgColor: String
    var navbarLogoImageUrl: String
    
    init() {
        token = ""
        referer = ""
        competitionId = ""
        calendarId = ""
        imageBaseUrl = ""
        showTeam = false
        numberOfMatches = 3
        navbarBgColor = ""
        navbarLogoImageUrl = ""
    }

    init(token: String,
         referer: String,
         competitionId: String,
         calendarId: String,
         imageBaseUrl: String,
         showTeam: String,
         numberOfMatches: String,
         navbarBgColor: String,
         navbarLogoImageUrl: String) {
        self.token = token
        self.referer = referer
        self.competitionId = competitionId
        self.calendarId = calendarId
        self.imageBaseUrl = imageBaseUrl
        self.showTeam = showTeam.boolValue()
        self.numberOfMatches = Int(numberOfMatches) ?? 3
        self.navbarBgColor = navbarBgColor
        self.navbarLogoImageUrl = navbarLogoImageUrl
    }
}
