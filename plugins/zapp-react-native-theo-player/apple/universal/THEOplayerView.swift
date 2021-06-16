import Foundation
import React
import THEOplayerSDK
import UIKit
import XrayLogger
import ZappCore

@objc(THEOplayerView)
class THEOplayerView: UIView {
    var listeners: [String: EventListener] = [:]
//    private static var eventEmitter: ReactNativeEventEmitter!

    var player: THEOplayer!
    lazy var pluginModel: ZPPluginModel? = {
        FacadeConnector.connector?.pluginManager?.plugin(for: "zapp-react-native-theo-player")
    }()

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
    @objc var onAdBreakBegin: RCTBubblingEventBlock?
    @objc var onAdBreakEnd: RCTBubblingEventBlock?
    @objc var onAdError: RCTBubblingEventBlock?
    @objc var onAdBegin: RCTBubblingEventBlock?
    @objc var onAdEnd: RCTBubblingEventBlock?

    @objc var configurationData: NSDictionary? {
        didSet {
            setupTheoPlayer()
        }
    }

    @objc var source: SourceDescription? {
        didSet {
            player?.source = source
        }
    }

    @objc var autoplay: Bool = true {
        didSet {
            logger?.debugLog(message: "Autoplay enabled: \(autoplay)",
                             data: ["autoplay": autoplay])
            player?.autoplay = autoplay
        }
    }

    @objc var fullscreenOrientationCoupling: Bool = false {
        didSet {
            logger?.debugLog(message: "Full screen Orientation coupling: \(fullscreenOrientationCoupling)",
                             data: ["fullscreenOrientationCoupling": fullscreenOrientationCoupling])
            player?.fullscreenOrientationCoupling = fullscreenOrientationCoupling
        }
    }

    deinit {
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
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
        player?.frame = frame
        player?.autoresizingMask = [.flexibleBottomMargin, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleWidth]
    }

    private func setupView() {
        // Set the background colour to THEO blue
        backgroundColor = .black
    }

    private func unloadTheoPlayer() {
        logger?.debugLog(message: "Unload player")
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
        onAdBreakBegin = nil
        onAdBreakEnd = nil
        onAdBegin = nil
        onAdEnd = nil
        onAdError = nil
        onPlayerPresentationModeChange = nil
        onJSWindowEvent = nil
        source = nil
    }

    // MARK: - THEOplayer setup and unload

    private func setupTheoPlayer() {
        logger?.debugLog(message: "Initialize player",
                         data: [:])
        let theoplayerLicenseKey = configurationData?["theoplayer_license_key"] as? String
        let playerScaleMode = configurationData?["theoplayer_scale_mode"] as? String

        var analytics = [AnalyticsDescription]()
        if let moatPartnerCode = configurationData?["moat_partner_code"] as? String {
            analytics.append(MoatOptions(partnerCode: moatPartnerCode,
                                         debugLoggingEnabled: true))
        }

        let bundle = Bundle(for: THEOplayerView.self)
        let scripthPaths = [bundle.path(forResource: "script", ofType: "js")].compactMap { $0 }

        var stylePaths = [bundle.path(forResource: playerScaleMode, ofType: "css")].compactMap { $0 }
        if let customCss = urlForCustomCss() {
            stylePaths.append(customCss)
        }
        let playerConfig = THEOplayerConfiguration(chromeless: false,
                                                   defaultCSS: true,
                                                   cssPaths: stylePaths,
                                                   jsPaths: scripthPaths,
                                                   jsPathsPre: [],
                                                   analytics: analytics,
                                                   pip: PiPConfiguration(retainPresentationModeOnSourceChange: false),
                                                   ads: AdsConfiguration(showCountdown: true,
                                                                         preload: .NONE,
                                                                         googleImaConfiguration: GoogleIMAConfiguration(useNativeIma: true)), ui: nil,
                                                   cast: CastConfiguration(strategy: .auto),
                                                   hlsDateRange: nil,
                                                   license: theoplayerLicenseKey,
                                                   licenseUrl: nil,
                                                   verizonMedia: nil)

        player = THEOplayer(configuration: playerConfig)
        /*
            Evaluate main script function declarated in theoplayer.js(custom js)
            You can init pure js code without file by evaluateJavaScript.
         */
        player.evaluateJavaScript("init({player: player})")
        player.presentationMode = .inline

        attachJSEventListeners()
        attachEventListeners()
        player.autoplay = autoplay
        player.source = source
        player.fullscreenOrientationCoupling = fullscreenOrientationCoupling
        player.addAsSubview(of: self)
        if autoplay {
            player.play()
        }
    }

    func urlForCustomCss() -> String? {
        guard let configurationJSON = pluginModel?.configurationJSON,
              let cssURL = configurationJSON["css_url"] as? String else {
            return nil
        }
        return cssURL
    }
}
