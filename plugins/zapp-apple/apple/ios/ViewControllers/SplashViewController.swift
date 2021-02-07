//
//  SplashViewController.swift
//  ZappTvOS
//
//  Created by Anton Kononenko on 11/13/18.
//  Copyright © 2018 Applicaster LTD. All rights reserved.
//

import AVKit
import UIKit
import XrayLogger
import ZappCore

class SplashViewController: UIViewController {
    lazy var logger = Logger.getLogger(for: SplashViewControllerLogs.subsystem)

    typealias LoadingCompletion = () -> Void
    open lazy var playerViewController = AVPlayerViewController()
    private var loadingCompletion: LoadingCompletion?
    private var rootViewController: RootController?

    @IBOutlet open var loadingView: UIActivityIndicatorView!
    @IBOutlet open var playerContainer: UIView!

    @IBOutlet var errorLabel: UILabel?

    lazy var videoURL: URL? = {
        var retVal: URL?
        let localMoviePath = DataManager.splashVideoPath()
        if let localMoviePath = localMoviePath,
           FileManager.default.fileExists(atPath: localMoviePath),
           String.isNotEmptyOrWhitespace(localMoviePath) {
            retVal = URL(fileURLWithPath: localMoviePath)
        }

        logger?.debugLog(template: SplashViewControllerLogs.videoURL,
                         data: ["url": localMoviePath ?? "no data",
                                "item_exist": retVal != nil])
        return retVal
    }()

    deinit {
        removeVideoObservers()
    }

    override open func awakeFromNib() {
        super.awakeFromNib()
        logger?.debugLog(template: SplashViewControllerLogs.splashViewControllerCreated)
        view.backgroundColor = UIColor.black
        prepareController()
    }

    func startAppLoading(rootViewController: RootController, completion: @escaping LoadingCompletion) {
        loadingView?.color = StylesHelper.color(forKey: CoreStylesKeys.loadingSpinnerColor)
        StylesHelper.updateLabel(forKey: CoreStylesKeys.loadingErrorLabel,
                                 label: errorLabel)
        errorLabel?.isHidden = true

        loadingView?.stopAnimating()
        loadingCompletion = completion
        self.rootViewController = rootViewController

        logger?.debugLog(template: SplashViewControllerLogs.splashViewConrollerStartAppLoadingTask)

        if let player = playerViewController.player {
            setPlayerItemIfNeeded()
            rootViewController.facadeConnector.audioSession?.enablePlaybackCategoryIfNeededToMuteBackgroundAudio(forItem: player.currentItem)
            player.play()
        } else {
            loadingView?.startAnimating()
            callLoadingCompletion()
        }
    }

    private func setPlayerItemIfNeeded() {
        if let player = playerViewController.player,
           player.currentItem == nil,
           let url = videoURL {
            playerViewController.player?.replaceCurrentItem(with: AVPlayerItem(url: url))
            addCurrentPlayedItemObservers()
        }
    }

    public func prepareController() {
        if let url = videoURL,
           let playerContainer = playerContainer,
           playerContainer.subviews.count == 0 {
            playerViewController.view.backgroundColor = UIColor.clear
            playerViewController.player = AVPlayer(url: url)
            playerViewController.player?.pause()
            playerViewController.showsPlaybackControls = false
            addChildViewController(childController: playerViewController,
                                   to: playerContainer)
            playerViewController.videoGravity = .resizeAspectFill

            addVideoObservers()

            logger?.debugLog(template: SplashViewControllerLogs.preparePlayerViewController,
                             data: ["url": url.absoluteURL,
                                    "video_gravity": "resize_aspect_fill",
                                    "showsPlaybackControls": playerViewController.showsPlaybackControls,
                                    "pause_player": true,
                                    "color": "clear"])
        } else {
            logger?.debugLog(template: SplashViewControllerLogs.preparePlayerViewControllerNoURL)
        }
    }

    func callLoadingCompletion() {
        logger?.debugLog(template: SplashViewControllerLogs.splashViewConrollerFinishedTask)
        loadingCompletion?()
        loadingCompletion = nil
    }

    func hideVideoPlayerContainer() {
        playerContainer?.isHidden = true
    }

    func addVideoObservers() {
        addCurrentPlayedItemObservers()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForeground(_:)),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground(_:)),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
    }

    func addCurrentPlayedItemObservers() {
        playerViewController.player?.currentItem?.addObserver(self,
                                                              forKeyPath: "status",
                                                              options: .new,
                                                              context: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlaying(_:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: playerViewController.player?.currentItem)
    }

    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if let playerItem = object as? AVPlayerItem {
            if playerItem.status == .failed {
                playerViewController.view.isHidden = true
                playerDidFinishTask()
            }
        }
    }

    func removeVideoObservers() {
        playerViewController.player?.currentItem?.removeObserver(self,
                                                                 forKeyPath: "status",
                                                                 context: nil)
    }

    @objc open func showErrorMessage(_ errorMessage: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.errorLabel?.isHidden = errorMessage.isEmpty ? true : false
            self.errorLabel?.text = errorMessage
            self.loadingView?.startAnimating()
            self.logger?.debugLog(template: SplashViewControllerLogs.showErrorMessage,
                                  data: ["error_message": errorMessage])
        }
    }

    open func playerDidFinishTask() {
        var loggerData: [String: Any] = [:]
        if errorLabel == nil || errorLabel?.isHidden == true {
            loadingView?.startAnimating()
        } else {
            loggerData["error_message"] = errorLabel?.text
        }

        logger?.debugLog(template: SplashViewControllerLogs.playerVIewControllerFinished,
                         data: loggerData)
        callLoadingCompletion()
    }
}

extension SplashViewController {
    @objc func playerDidFinishPlaying(_ note: Notification) {
        rootViewController?.facadeConnector.audioSession?.notifyBackgroundAudioToContinuePlaying()
        playerViewController.player?.replaceCurrentItem(with: nil)
        playerDidFinishTask()
    }

    @objc func willEnterForeground(_ notification: Notification) {
        rootViewController?.facadeConnector.audioSession?.enablePlaybackCategoryIfNeededToMuteBackgroundAudio(forItem: playerViewController.player?.currentItem)
        playerViewController.player?.play()
    }

    @objc func didEnterBackground(_ notification: Notification) {
        if playerViewController.player?.isPlaying == true {
            rootViewController?.facadeConnector.audioSession?.disableAudioSession()
            playerViewController.player?.pause()
        }
    }
}

extension AVPlayer {
    var isPlaying: Bool {
        return ((rate != 0) && (error == nil))
    }
}
