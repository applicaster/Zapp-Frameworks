import Foundation
import THEOplayerSDK
import UIKit
import React

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

    @objc var source: SourceDescription? {
        didSet {
            player.source = source
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
        unloadTheoPlayer()
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

    override func layoutSubviews() {
        super.layoutSubviews()
        player.frame = frame
        player.autoresizingMask = [.flexibleBottomMargin, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleWidth]
    }

    private func setupView() {
        // Set the background colour to THEO blue
        backgroundColor = .black
    }

    // TODO: check who is calling
    private func unloadTheoPlayer() {
        removeEventListeners()
        player.stop()
        player.destroy()
    }

    // MARK: - THEOplayer setup and unload

    private func setupTheoPlayer() {
        
//        let playerConfig = THEOplayerConfiguration(chromeless: true, pip: nil)
//        player = THEOplayer(configuration: playerConfig)
        player = THEOplayer()
        /*
            Evaluate main script function declarated in theoplayer.js(custom js)
            You can init pure js code without file by evaluateJavaScript.
         */
        player.evaluateJavaScript("init({player: player})")
        player.presentationMode = .fullscreen

        attachEventListeners()
        player.addAsSubview(of: self)
    }
}
