//
//  SplashViewController.swift
//  ZappTvOS
//
//  Created by Anton Kononenko on 11/13/18.
//  Copyright © 2018 Anton Kononenko. All rights reserved.
//

import AVKit
import UIKit
import ZappCore

class SplashViewController: UIViewController {
    typealias LoadingCompletion = () -> Void
    open lazy var playerViewController = AVPlayerViewController()
    private var loadingCompletion: LoadingCompletion?
    private var rootViewController: RootController?
    
    @IBOutlet open var imageView: UIImageView!
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
        return retVal
    }()

    deinit {
        removeVideoObservers()
    }

    open override func awakeFromNib() {
        super.awakeFromNib()

        view.backgroundColor = UIColor.black
        addSplashImage()
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
        
        if let player = playerViewController.player {
            rootViewController.facadeConnector.audioSession?.enablePlaybackCategoryIfNeededToMuteBackgroundAudio(forItem: player.currentItem)
            player.play()
        } else {
            loadingView?.startAnimating()
            callLoadingCompletion()
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
        }
    }

    func addSplashImage() {
        // Check issue if future - https://stackoverflow.com/questions/19410066/ios-7-xcode-5-access-device-launch-images-programmatically
        imageView?.image = LocalSplashHelper.localSplashImage(for: self)
    }

    func callLoadingCompletion() {
        loadingCompletion?()
        loadingCompletion = nil
    }

    func hideVideoPlayerContainer() {
        playerContainer?.isHidden = true
    }

    func addVideoObservers() {
        playerViewController.player?.currentItem?.addObserver(self,
                                                              forKeyPath: "status",
                                                              options: .new,
                                                              context: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlaying(_:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: playerViewController.player?.currentItem)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForeground(_:)),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground(_:)),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
    }

    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
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
            self?.errorLabel?.isHidden = errorMessage.isEmpty ? true : false
            self?.errorLabel?.text = errorMessage
            self?.loadingView?.startAnimating()
        }
    }

    open func playerDidFinishTask() {
        if errorLabel == nil || errorLabel?.isHidden == true {
            loadingView?.startAnimating()
        }
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
