//
//  OptaStats+HandleUrlScheme.swift
//  OptaStats
//
//  Created by Alex Zchut on 15/04/2021.
//

import Foundation
import ZappCore

extension OptaStats: PluginURLHandlerProtocol {
    public func handlePluginURLScheme(with rootViewController: UIViewController?, url: URL) -> Bool {
        var retValue = false

        // ca2019://plugin?type=general&action=stats_open_screen&screen_id=team_screen&team_id=10
        // xcrun simctl openurl booted "ca2019://plugin?type=general&action=stats_open_screen&match_id=10"

        guard let params = queryParams(url: url),
              let action = params["action"] as? String else {
            return false
        }

        switch action {
        case "stats_open_screen":
            retValue = handlePresentScreen(targetViewController: rootViewController,
                                           params: params)
        default:
            break
        }

        return retValue
    }

    func queryParams(url: URL) -> [String: Any]? {
        guard let components = URLComponents(url: url,
                                             resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { result, item in
            result[item.name] = item.value
        }
    }
}

extension OptaStats {
    fileprivate func handlePresentScreen(targetViewController: UIViewController?,
                                         params: [String: Any]) -> Bool {
        guard let screenID = params["screen_id"] as? String else { return false }

        var viewControllerToShow: ViewControllerBase?

        var fromPushNotification = false

        if let value = params["push"] as? String,
           let valueAsBool = Helpers.boolFromString(value) {
            fromPushNotification = valueAsBool
        }

        if let screenType = StatsScreenTypes(rawValue: screenID) {
            switch screenType {
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
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "GenericViewController") as? GenericViewController
                viewController?.screenName = screenID
                viewControllerToShow = viewController
            }
        } else {
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "GenericViewController") as? GenericViewController
            viewController?.screenName = screenID
            viewControllerToShow = viewController
        }

        if let vc = viewControllerToShow {
            replaceViewController(with: vc,
                                  on: targetViewController,
                                  present: true)
        }

        return true
    }

    func replaceViewController(with newViewController: UIViewController?,
                               on targetViewController: UIViewController?,
                               present: Bool = false) {
        if let childVC = currentChildViewController?.view {
            childVC.removeFromSuperview()
            currentChildViewController = nil
        }

        if let presentVC = currentPresentedViewController {
            presentVC.dismiss(animated: true, completion: nil)
        }

        if present, let newViewController = newViewController {
            let navController = NavigationController(rootViewController: newViewController)
            presentController(viewController: navController, on: targetViewController)
        } else if let newView = newViewController?.view {
            newView.translatesAutoresizingMaskIntoConstraints = false
            targetView?.addSubview(newView)
            currentChildViewController = newViewController
            targetView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[newView]-0-|", options: [], metrics: nil, views: ["newView": newView]))
            targetView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[newView]-0-|", options: [], metrics: nil, views: ["newView": newView]))
        }
    }

    fileprivate func presentController(viewController: UIViewController, on targetViewController: UIViewController?) {
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
