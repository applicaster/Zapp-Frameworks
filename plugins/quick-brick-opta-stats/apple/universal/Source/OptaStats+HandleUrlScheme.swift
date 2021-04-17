//
//  OptaStats+HandleUrlScheme.swift
//  OptaStats
//
//  Created by Alex Zchut on 15/04/2021.
//

import Foundation

extension OptaStats {
    public func handleUrlScheme(_ params: NSDictionary) {
        // ca2019://plugin?type=general&action=stats_open_screen&screen_id=team_screen&team_id=10
        // xcrun simctl openurl booted "ca2019://plugin?type=general&action=stats_open_screen&match_id=10"

        guard let action = params["action"] as? String else {
            return
        }

        switch action {
        case "stats_open_screen":
            handleOpenScreen(params)
        default:
            break
        }
    }

    fileprivate func handleOpenScreen(_ params: NSDictionary) {
        guard let screenID = params["screen_id"] as? String else { return }

        var viewControllerToShow: ViewControllerBase?

        var fromPushNotification = false

        if let value = params["push"] as? String,
           let valueAsBool = Helpers.boolFromString(value) {
            fromPushNotification = valueAsBool
        }

        if let screenType = StatsScreenTypes(rawValue: screenID) {
            switch screenType {
            case .groupScreen:
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: GroupCardsViewController.storyboardID) as! GroupCardsViewController
                viewControllerToShow = viewController
            case .teamScreen:
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: TeamCardViewController.storyboardID) as! TeamCardViewController
                if let teamID = params["team_id"] as? String {
                    viewController.teamID = teamID
                }
                viewControllerToShow = viewController
            case .matchesScreen:
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: MatchesCardViewController.storyboardID) as! MatchesCardViewController
                if let teamID = params["team_id"] as? String {
                    viewController.teamID = teamID
                }
                viewControllerToShow = viewController
            case .matchScreen:
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: MatchDetailViewController.storyboardID) as! MatchDetailViewController
                if let matchID = params["match_id"] as? String {
                    viewController.matchID = Helpers.sanatizeID(matchID, fromPush: fromPushNotification)
                }
                viewControllerToShow = viewController
            case .playerScreen:
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: PlayerDetailsViewController.storyboardID) as! PlayerDetailsViewController
                if let playerID = params["player_id"] as? String {
                    viewController.playerID = playerID
                }
                viewControllerToShow = viewController
            default:
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "GenericViewController") as! GenericViewController
                viewController.screenName = screenID
                viewControllerToShow = viewController
            }
        } else {
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "GenericViewController") as! GenericViewController
            viewController.screenName = screenID
            viewControllerToShow = viewController
        }

        if let vc = viewControllerToShow {
            replaceViewController(with: vc)
        }
    }

    func replaceViewController(with newViewController: UIViewController?, present: Bool = false) {
        if let childVC = currentChildViewController?.view {
            childVC.removeFromSuperview()
            currentChildViewController = nil
        }

        if let presentVC = currentPresentedViewController {
            presentVC.dismiss(animated: true, completion: nil)
        }

        if present, let newViewController = newViewController {
            let navController = NavigationController(rootViewController: newViewController)
            presentController(viewController: navController)
        } else if let newView = newViewController?.view {
            newView.translatesAutoresizingMaskIntoConstraints = false
            targetView?.addSubview(newView)
            currentChildViewController = newViewController
            targetView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[newView]-0-|", options: [], metrics: nil, views: ["newView": newView]))
            targetView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[newView]-0-|", options: [], metrics: nil, views: ["newView": newView]))
        }
    }

    fileprivate func presentController(viewController: UIViewController) {
        var topmostViewController = UIApplication.shared.windows.first?.rootViewController
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
