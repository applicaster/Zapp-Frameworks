import Foundation
import MoPub
import React
import THEOplayerSDK
import UIKit

@objc(THEOplayerView)
class THEOplayerView: UIView {
    // TODO: check if need to move to some another place
    var castContextSet: Bool = false

    var listeners: [String: EventListener] = [:]
//    private static var eventEmitter: ReactNativeEventEmitter!

    var player: THEOplayer!

    @objc var onPlayerPlay: RCTBubblingEventBlock?
    @objc var onPlayerPlaying: RCTBubblingEventBlock?
    @objc var onPlayerPause: RCTBubblingEventBlock?
    @objc var onPlayerProgress: RCTBubblingEventBlock?
    @objc var onPlayerSeeking: RCTBubblingEventBlock?
    @objc var onPlayerSeeked: RCTBubblingEventBlock?
    @objc var onPlayerWaiting: RCTBubblingEventBlock?
    @objc var onPlayerTimeUpdate: RCTBubblingEventBlock?
    @objc var onPlayerRateChange: RCTBubblingEventBlock?
    @objc var onPlayerReadyStateChange: RCTBubblingEventBlock?
    @objc var onPlayerLoadedMetaData: RCTBubblingEventBlock?
    @objc var onPlayerLoadedData: RCTBubblingEventBlock?
    @objc var onPlayerLoadStart: RCTBubblingEventBlock?
    @objc var onPlayerCanPlay: RCTBubblingEventBlock?
    @objc var onPlayerCanPlayThrough: RCTBubblingEventBlock?
    @objc var onPlayerDurationChange: RCTBubblingEventBlock?
    @objc var onPlayerSourceChange: RCTBubblingEventBlock?
    @objc var onPlayerPresentationModeChange: RCTBubblingEventBlock?
    @objc var onPlayerVolumeChange: RCTBubblingEventBlock?
    @objc var onPlayerResize: RCTBubblingEventBlock?
    @objc var onPlayerDestroy: RCTBubblingEventBlock?
    @objc var onPlayerEnded: RCTBubblingEventBlock?
    @objc var onPlayerError: RCTBubblingEventBlock?
    @objc var onJSWindowEvent: RCTBubblingEventBlock?
    @objc var licenceData: NSDictionary?

    @objc var source: SourceDescription? {
        didSet {
            player?.source = source
        }
    }

    @objc var autoplay: Bool = false {
        didSet {
            player.autoplay = autoplay
        }
    }

    @objc var fullscreenOrientationCoupling: Bool = false {
        didSet {
            player.fullscreenOrientationCoupling = fullscreenOrientationCoupling
        }
    }

    deinit {
    }

    override init(frame: CGRect) {
        if castContextSet == false {
            THEOplayerCastHelper.setGCKCastContextSharedInstanceWithDefaultCastOptions()
            castContextSet = true
        }
        super.init(frame: frame)
        setupView()
        setupTheoPlayer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override public func removeReactSubview(_ subview: UIView?) {
        subview?.removeFromSuperview()
    }

    override public func removeFromSuperview() {
        unloadTheoPlayer()
        super.removeFromSuperview()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        player.frame = frame
        player.autoresizingMask = [.flexibleBottomMargin, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleWidth]
    }

    private func setupView() {
        // Set the background colour to THEO blue
        backgroundColor = .black
    }

    private func unloadTheoPlayer() {
        removeJSEventListeners()
        removeEventListeners()
        player.stop()
        player.destroy()
        player = nil
        onPlayerPlay = nil
        onPlayerPlaying = nil
        onPlayerPause = nil
        onPlayerProgress = nil
        onPlayerSeeking = nil
        onPlayerSeeked = nil
        onPlayerWaiting = nil
        onPlayerTimeUpdate = nil
        onPlayerRateChange = nil
        onPlayerReadyStateChange = nil
        onPlayerLoadedMetaData = nil
        onPlayerLoadedData = nil
        onPlayerLoadStart = nil
        onPlayerCanPlay = nil
        onPlayerCanPlayThrough = nil
        onPlayerDurationChange = nil
        onPlayerSourceChange = nil
        onPlayerVolumeChange = nil
        onPlayerResize = nil
        onPlayerDestroy = nil
        onPlayerEnded = nil
        onPlayerError = nil
        onJSWindowEvent = nil
        onPlayerPresentationModeChange = nil
        source = nil
    }

    // MARK: - THEOplayer setup and unload

    private func setupTheoPlayer() {
        let theoplayerLicenseKey = licenceData?["theoplayer_license_key"] as? String

        var analytics = [AnalyticsDescription]()
        if let moatPartnerCode = licenceData?["moat_partner_code"] as? String {
            analytics.append(MoatOptions(partnerCode: moatPartnerCode,
                                         debugLoggingEnabled: true))
        }
        
        let bundle = Bundle(for: THEOplayerView.self)
        let scripthPaths = [bundle.path(forResource: "script", ofType: "js")].compactMap { $0 }
        let stylePaths = [bundle.path(forResource: "style", ofType: "css")].compactMap { $0 }
        let playerConfig = THEOplayerConfiguration(chromeless: false,
                                                   defaultCSS: true,
                                                   cssPaths: stylePaths,
                                                   jsPaths: scripthPaths,
                                                   jsPathsPre: [],
                                                   analytics: analytics,
                                                   pip: nil,
                                                   ads: AdsConfiguration(showCountdown: true,
                                                                         preload: .NONE,
                                                                         googleImaConfiguration: GoogleIMAConfiguration(useNativeIma: true)), ui: nil,
                                                   cast: CastConfiguration(strategy: .auto),
                                                   hlsDateRange: nil,
                                                   license: theoplayerLicenseKey,
                                                   licenseUrl: nil,
                                                   verizonMedia: nil)
//        let playerConfig = THEOplayerConfiguration(chromeless: false,
//                                                   license: "ffdff",
//                                                   cssPaths: stylePaths,
//                                                   jsPathsPre: scripthPaths,
//                                                   pip: nil,
//                                                   ads: AdsConfiguration(showCountdown: true, preload: .NONE,
//                                                                         googleImaConfiguration: GoogleIMAConfiguration(useNativeIma: true)),
//                                                   cast: CastConfiguration(strategy: .auto))

        player = THEOplayer(configuration: playerConfig)

        /*
            Evaluate main script function declarated in theoplayer.js(custom js)
            You can init pure js code without file by evaluateJavaScript.
         */
        player.evaluateJavaScript("init({player: player})")
        player.presentationMode = .inline

        attachJSEventListeners()
        attachEventListeners()
        player.addAsSubview(of: self)
    }
}
