//
//  OptaStats+HandleUrlScheme.swift
//  OptaStats
//
//  Created by Alex Zchut on 15/04/2021.
//

import Foundation
import ZappCore

extension OptaStats: PluginURLHandlerProtocol {
    struct Actions {
        static let show = "show"
        static let stats = "stats"
        static let showstats = "showstats"
    }
    
    struct UrlParams {
        static let action = "action"
        static let type = "type"
        static let id = "id"
    }

    public func handlePluginURLScheme(with rootViewController: UIViewController?, url: URL) -> Bool {
        // ca2019://plugin?pluginIdentifier=quick-brick-opta-stats&action=show&type=match&id=bgmp0pbbzbwmubds90nirsyui
        // xcrun simctl openurl booted "ca2019://plugin?pluginIdentifier=quick-brick-opta-stats&action=show&type=match&id=bgmp0pbbzbwmubds90nirsyui"

        guard let params = getParams(from: url) else {
            return false
        }

        return handlePresentScreen(targetViewController: rootViewController,
                                   params: params)
    }

    public func canHandlePluginURLScheme(with url: URL) -> Bool {
        var retValue = false

        guard let params = getParams(from: url),
              let action = params["action"] as? String else {
            return false
        }

        switch action {
        case Actions.show,
             Actions.stats,
             Actions.showstats:
            retValue = screenType(for: params) != .undefined
        default:
            break
        }

        return retValue
    }

    fileprivate func getParams(from url: URL) -> [String: Any]? {
        var params:[String: Any] = [:]
        if let queryParams = queryStringParams(from: url) {
            params = queryParams
        }
        else if var pathComponents = getPathComponents(from: url) {
            params[UrlParams.action] = pathComponents.first
            pathComponents = getPathComponentsDroppingFirst(pathComponents)
            if pathComponents.count > 0 {
                params[UrlParams.type] = pathComponents.first
            }
            pathComponents = getPathComponentsDroppingFirst(pathComponents)
            if pathComponents.count > 0 {
                params[UrlParams.id] = pathComponents.first
            }
        }
        return params
    }
    
    fileprivate func queryStringParams(from url: URL) -> [String: Any]? {
        guard let components = URLComponents(url: url,
                                             resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { result, item in
            result[item.name] = item.value
        }
    }
    
    fileprivate func getPathComponents(from url: URL) -> [String]? {
        let pathComponents = url.pathComponents.dropFirst()
        guard pathComponents.count > 0 else { return [] }
        return Array(pathComponents)
    }
    
    fileprivate func getPathComponentsDroppingFirst(_ pathComponents: [String]) -> [String] {
        return Array(pathComponents.dropFirst())
    }
}

extension OptaStats {
    fileprivate func screenType(for params: [String: Any]) -> StatsScreenType {
        guard let screenTypeValue = params["type"] as? String,
              let type = StatsScreenType(rawValue: screenTypeValue) else {
            return .undefined
        }

        return type
    }

    func handlePresentScreen(targetViewController: UIViewController?,
                             screenArguments: [String: Any]) -> Bool {
        guard let urlString = screenArguments["url"] as? String,
              let url = URL(string: urlString),
              let params = getParams(from: url) else {
            return false
        }
        
        return handlePresentScreen(targetViewController: targetViewController, params: params)
    }
    
    func handlePresentScreen(targetViewController: UIViewController?,
                                         params: [String: Any]) -> Bool {
        var retValue = true

        var viewControllerToShow: ViewControllerBase?

        var fromPushNotification = false

        if let value = params["push"] as? String,
           let valueAsBool = Helpers.boolFromString(value) {
            fromPushNotification = valueAsBool
        }

        switch screenType(for: params) {
        case .groupScreen:
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: GroupCardsViewController.storyboardID) as? GroupCardsViewController
            viewControllerToShow = viewController
        case .teamScreen:
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: TeamCardViewController.storyboardID) as? TeamCardViewController
            if let teamID = params["team_id"] as? String {
                viewController?.teamID = teamID
            }
            viewControllerToShow = viewController
        case .matchesScreen:
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: MatchesCardViewController.storyboardID) as? MatchesCardViewController
            if let teamID = params["team_id"] as? String {
                viewController?.teamID = teamID
            }
            viewControllerToShow = viewController
        case .matchScreen:
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: MatchDetailViewController.storyboardID) as? MatchDetailViewController
            if let matchID = params["match_id"] as? String {
                viewController?.matchID = Helpers.sanatizeID(matchID, fromPush: fromPushNotification)
            }
            viewControllerToShow = viewController
        case .playerScreen:
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: PlayerDetailsViewController.storyboardID) as? PlayerDetailsViewController
            if let playerID = params["player_id"] as? String {
                viewController?.playerID = playerID
            }
            viewControllerToShow = viewController
        default:
            retValue = false
            break
        }

        if let vc = viewControllerToShow {
            replaceViewController(with: vc,
                                  on: targetViewController,
                                  present: true)
        }

        return retValue
    }

    func replaceViewController(with newViewController: ViewControllerBase?,
                               on targetViewController: UIViewController?,
                               present: Bool = false) {
        if let presentVC = currentPresentedViewController {
            presentVC.dismiss(animated: true, completion: nil)
        }

        guard let newViewController = newViewController else {
            return
        }

        if present {
            OptaStats.presentViewControllerModally(viewController: newViewController, on: targetViewController)
        } else if let newView = newViewController.view {
            if let childVC = currentChildViewController?.view {
                childVC.removeFromSuperview()
                currentChildViewController = nil
            }
            newView.translatesAutoresizingMaskIntoConstraints = false
            targetView?.addSubview(newView)
            currentChildViewController = newViewController
            targetView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[newView]-0-|", options: [], metrics: nil, views: ["newView": newView]))
            targetView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[newView]-0-|", options: [], metrics: nil, views: ["newView": newView]))
        }
    }

    static func presentViewControllerModally(viewController: ViewControllerBase, on target: UIViewController? = nil) {
        var targetViewController = target
        if targetViewController == nil {
            targetViewController = UIApplication.shared.keyWindow?.rootViewController
        }

        let navigationController = NavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.navigationBar.setBackgroundImage(targetViewController?.navigationController?.navigationBar.backgroundImage(for: .default), for: .default)
        viewController.isModalPresentation = true

        presentController(navigationController, on: targetViewController)
    }

    static func presentController(_ viewController: UIViewController, on targetViewController: UIViewController?) {
        var topmostViewController = targetViewController
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) {
            while topmostViewController?.presentedViewController != nil {
                topmostViewController = topmostViewController?.presentedViewController
            }

            if let vc = topmostViewController {
                vc.present(viewController, animated: true, completion: nil)
            }
        }
    }
}
