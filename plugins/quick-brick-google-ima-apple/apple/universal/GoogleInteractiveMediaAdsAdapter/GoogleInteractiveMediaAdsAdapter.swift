//
//  ImaPluginAdapter.swift
//  GoogleInteractiveMediaAds
//
//  Created by Anton Kononenko on 7/17/19.
//  Copyright (c) 2020 Applicaster. All rights reserved.
//

import AVFoundation
import GoogleInteractiveMediaAds
import UIKit
import ZappCore

@objc public class GoogleInteractiveMediaAdsAdapter: NSObject, PlayerDependantPluginProtocol {
    public required init(pluginModel: ZPPluginModel) {
        model = pluginModel
        configurationJSON = pluginModel.configurationJSON
    }

    public var model: ZPPluginModel?

    public var providerName: String {
        return "Google Interactive Media Ads"
    }

    public func prepareProvider(_ defaultParams: [String: Any],
                                completion: ((Bool) -> Void)?) {
        completion?(true)
    }

    public func disable(completion: ((Bool) -> Void)?) {
        adsLoader?.delegate = nil
        adsManager?.delegate = nil
        completion?(true)
    }

    var activityIndicator = UIActivityIndicatorView()
    var isVMAPAdsCompleted = false
    var isPlaybackPaused = false
    var isPrerollAdLoading = false {
        didSet {
            updatePresentationOfActivityIndicatorIfNeeded()
        }
    }

    /// Player plugin instance that currently presented
    public weak var playerPlugin: PlayerProtocol?
    var postrollCompletion: ((_ finished: Bool) -> Void)?
    var adRequest: IMAAdsRequest?
    public var configurationJSON: NSDictionary?

    /// Entry point for the SDK. Used to make ad requests.
    internal var adsLoader: IMAAdsLoader?

    /// Playhead used by the SDK to track content video progress and insert mid-rolls.
    internal var contentPlayhead: IMAAVPlayerContentPlayhead?

    /// Main point of interaction with the SDK. Created by the SDK as the result of an ad request.
    internal var adsManager: IMAAdsManager?

    internal var adDisplayContainer: IMAAdDisplayContainer?

    internal var advAccessibilityIdentifier: String?

    var avPlayer: AVPlayer? {
        return playerPlugin?.playerObject as? AVPlayer
    }

    var urlTagData: GoogleUrlTagData?

    func prepareGoogleIMA() -> Bool {
        var shouldContinuePlaying = true
        isPlaybackPaused = false
        isVMAPAdsCompleted = false
        isPrerollAdLoading = false
        guard let player = avPlayer else { return shouldContinuePlaying }
        addNotificationsObserver()
        addRateObserver()

        urlTagData = GoogleUrlTagData(entry: playerPlugin?.entry,
                                      pluginParams: configurationJSON)
        contentPlayhead = IMAAVPlayerContentPlayhead(avPlayer: player)

        if let urlToPresent = urlTagData?.prerollUrlString() {
            isPrerollAdLoading = true
            shouldContinuePlaying = false
            GoogleInteractiveMediaAdsAdapterTrackingIdentifier.requestTrackingAuthorization {
                DispatchQueue.main.async {
                    self.requestAd(adUrl: urlToPresent)
                }
            }
        }
        return shouldContinuePlaying
    }

    func addNotificationsObserver() {
        let defaultCenter = NotificationCenter.default

        defaultCenter.addObserver(self,
                                  selector: #selector(applicationWillResignActive(notification:)),
                                  name: UIApplication.willResignActiveNotification,
                                  object: nil)

        defaultCenter.addObserver(self,
                                  selector: #selector(applicationDidBecomeActive(notification:)),
                                  name: UIApplication.didBecomeActiveNotification,
                                  object: nil)
    }

    @objc func applicationWillResignActive(notification: Notification) {
        adsManager?.pause()
    }

    @objc func applicationDidBecomeActive(notification: Notification) {
        adsManager?.resume()
    }

    func addRateObserver() {
        avPlayer?.addObserver(self, forKeyPath: MediaAdsConstants.playerPlaybackRate, options: NSKeyValueObservingOptions.new, context: nil)
    }

    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == MediaAdsConstants.playerPlaybackRate {
            if let player = avPlayer, player.rate > 0 && isPlaybackPaused {
                avPlayer?.pause()
            }
        }
    }

    func resumePlayback() {
        isPlaybackPaused = false
        playerPlugin?.pluggablePlayerResume()

        if adDisplayContainer == adDisplayContainer {
            adDisplayContainer?.adContainer.accessibilityIdentifier = ""
        }
    }

    func pausePlayback() {
        isPlaybackPaused = true
        playerPlugin?.pluggablePlayerPause()

        if adDisplayContainer == adDisplayContainer {
            adDisplayContainer?.adContainer.accessibilityIdentifier = advAccessibilityIdentifier
        }
    }

    func updatePresentationOfActivityIndicatorIfNeeded() {
        if isPrerollAdLoading {
            activityIndicator.color = .gray
            activityIndicator.backgroundColor = .black
            
            if let contentOverlay = (self.playerPlugin?.pluginPlayerViewController as? AVPlayerViewController)?.contentOverlayView,
               self.activityIndicator.superview == nil {
                contentOverlay.addSubview(self.activityIndicator)
                activityIndicator.translatesAutoresizingMaskIntoConstraints = false
                activityIndicator.widthAnchor.constraint(equalTo: contentOverlay.widthAnchor, multiplier: 1.0).isActive = true
                activityIndicator.heightAnchor.constraint(equalTo: contentOverlay.heightAnchor, multiplier: 1.0).isActive = true
                activityIndicator.startAnimating()
            }
            else if let playerView = self.playerPlugin as? UIView,
                    let playerLayer = playerView.layer.sublayers?.first(where: { $0 is AVPlayerLayer}) {
                activityIndicator.frame = playerLayer.bounds
                playerLayer.addSublayer(activityIndicator.layer)
                activityIndicator.startAnimating()
            }

        } else {
            self.activityIndicator.removeFromSuperview()
            self.activityIndicator.layer.removeFromSuperlayer()
        }
    }

    func setupAdsLoader() {
        let settings = IMASettings()
        settings.enableDebugMode = false
        adsLoader = IMAAdsLoader(settings: settings)
        adsLoader?.delegate = self
    }

    func requestAd(adUrl: String) {
        guard let contentPlayhead = contentPlayhead,
              let topViewController = UIApplication.shared.keyWindow?.rootViewController else {
            return
        }
        setupAdsLoader()

        #if os(tvOS)
            adDisplayContainer = IMAAdDisplayContainer(adContainer: topViewController.view,
                                                       viewController: topViewController)
        #else

            adDisplayContainer = IMAAdDisplayContainer(adContainer: topViewController.view,
                                                       viewController: topViewController,
                                                       companionSlots: nil)
        #endif
        if let request = IMAAdsRequest(adTagUrl: adUrl,
                                       adDisplayContainer: adDisplayContainer,
                                       contentPlayhead: contentPlayhead,
                                       userContext: nil) {
            adRequest = request
            adsLoader?.requestAds(with: adRequest)

            // Storing accessibility identifier for UI automation tests needs
            advAccessibilityIdentifier = adUrl
        }
    }
}
