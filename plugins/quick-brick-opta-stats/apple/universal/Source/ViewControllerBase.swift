//
//  ViewControllerBase.swift
//  OptaStats
//
//  Created by Jesus De Meyer on 4/1/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import UIKit
import ZappPlugins

enum HeartbeatState: Int {
    case disabled
    case enabled
}

class ViewControllerBase: UIViewController {
    public lazy var mainStoryboard: UIStoryboard = {
        UIStoryboard(name: "StatsViewControllers", bundle: Bundle(for: self.classForCoder))
    }()

    var isModalPresentation: Bool = false // used when we trigger this VC through url scheme

    fileprivate var heartbeatState: HeartbeatState = .disabled {
        didSet {
            if let timer = heartbeatTimer {
                timer.invalidate()
                heartbeatTimer = nil
            }

            switch heartbeatState {
            case .disabled:
                break
            case .enabled:
                heartbeatTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
                    self.heartbeatBlock?()
                }
            }
        }
    }

    fileprivate var savedHeartbeatState: HeartbeatState?
    var heartbeatBlock: (() -> Void)?

    fileprivate var heartbeatTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        if isModalPresentation {
            // self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDismiss(_:)))
            setNavigation(with: .genericModal(vc: self))
        } else {
            setNavigation(with: .genericPushed(vc: self))
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let state = savedHeartbeatState {
            heartbeatState = state
            if state == .enabled {
                heartbeatBlock?()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        savedHeartbeatState = heartbeatState
        heartbeatState = .disabled
    }

    @objc
    func handleDismiss(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @objc
    func dismissAction() {
        if let navController = navigationController {
            if navController.viewControllers.count == 1 {
                dismiss(animated: true, completion: nil)
            } else {
                navController.popViewController(animated: true)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    func updateHeartbeat(liveData: LiveData?, force: Bool = false) {
        if let status = liveData?.matchDetails?.matchStatus?.lowercased() {
            if status == "played" {
                heartbeatState = .disabled
            } else if status == "fixture" {
                heartbeatState = force ? .enabled : .disabled
            } else if status == "playing" {
                heartbeatState = .enabled
            }
        } else {
            heartbeatState = force ? .enabled : .disabled
        }
    }

    func isLiveMatch(liveData: LiveData?) -> Bool {
        if let status = liveData?.matchDetails?.matchStatus, status.lowercased() != "fixture" && status.lowercased() == "playing" {
            return true
        }

        return false
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension Collection where Indices.Iterator.Element == Index {
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

enum StatsPluginNavigationType {
    case none
    case genericModal(vc: ViewControllerBase)
    case genericPushed(vc: ViewControllerBase)
}

extension UIViewController {
    func setNavigation(with navigationType: StatsPluginNavigationType) {
        let nav = navigationController?.navigationBar
        nav?.barStyle = .default
        nav?.isTranslucent = false
        nav?.barTintColor = UIColor(hex: "#141054")
        nav?.tintColor = UIColor.white
        nav?.backgroundColor = UIColor(hex: "#141054")

        var leftItem: UIBarButtonItem?
        var rightItems: [UIBarButtonItem]?
        loadTournamentLogo()

        switch navigationType {
        case .none:
            break
        case let .genericModal(vc):
            if let path = Bundle(for: classForCoder).path(forResource: "close-modal-icon", ofType: "png") {
                let closeButtonImage = UIImage(contentsOfFile: path)
                let closeButton = UIBarButtonItem(image: closeButtonImage, style: .plain, target: self, action: #selector(vc.dismissAction))
                rightItems = [closeButton]
                leftItem = nil
            }
        case let .genericPushed(vc):
            if let path = Bundle(for: classForCoder).path(forResource: "go-back-icon", ofType: "png") {
                let backButtonImage = UIImage(contentsOfFile: path)
                let backButton = UIBarButtonItem(image: backButtonImage, style: .plain, target: self, action: #selector(vc.dismissAction))
                rightItems = nil
                leftItem = backButton
            }
        }

        if let rightItems = rightItems {
            navigationItem.rightBarButtonItems = rightItems
        } else {
            navigationItem.rightBarButtonItem = nil
        }

        if let leftItem = leftItem {
            navigationItem.leftBarButtonItem = leftItem
        } else {
            navigationItem.leftBarButtonItem = nil
        }
    }

    func loadTournamentLogo() {
        if let path = Bundle(for: classForCoder).path(forResource: "logo", ofType: "png") {
            let logo = UIImage(contentsOfFile: path)
            let logoImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 116.36, height: 40))
            logoImageView.contentMode = .scaleAspectFill
            logoImageView.image = logo

            let logoView = UIView(frame: logoImageView.bounds)
            logoView.addSubview(logoImageView)
            navigationItem.titleView = logoView
        }
    }

    // MARK: -

    func showMatchDetailScreenWithStat(matchStat: MatchStatsCard) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: MatchDetailViewController.storyboardID) as? MatchDetailViewController {
            viewController.matchStat = matchStat
            showViewController(viewController)
        }
    }

    func showMatchDetailScreenWithID(matchID: String) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: MatchDetailViewController.storyboardID) as? MatchDetailViewController {
            viewController.matchID = matchID
            showViewController(viewController)
        }
    }

    func showAllMatchesScreen() {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: MatchesCardViewController.storyboardID) as? MatchesCardViewController {
            showViewController(viewController)
        }
    }

    func showTeamScreen(teamID: String) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: TeamCardViewController.storyboardID) as? TeamCardViewController {
            viewController.teamID = teamID
            showViewController(viewController)
        }
    }
    
    func showViewController(_ viewController: ViewControllerBase) {
        if self.navigationController != nil {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        else {
            OptaStats.presentViewControllerModally(viewController: viewController)
        }
    }
}
