import Foundation
import THEOplayerSDK

@objc(THEOplayerViewManager) class THEOplayerViewManager: RCTViewManager {

  var playerView = THEOplayerView()

  override func view() -> UIView! {
    return playerView
  }

  // Override implementation of queue setup
  // - Returns: when true class initialized on the main thread,
  //            when false class initialized on a background thread
  @objc
  override static func requiresMainQueueSetup() -> Bool {
    return true;
  }

  @objc
  func play() {
    playerView.player.play()
  }

  @objc
  func pause() {
    playerView.player.pause()
  }

  @objc
  func stop() {
    playerView.player.stop()
  }

  @objc
  func scheduleAd(_ jsAdDescription: [String : Any]) {
    do {
      let data = try JSONSerialization.data(withJSONObject: jsAdDescription)
      let adDescription = try JSONDecoder().decode(THEOAdDescription.self, from: data)
      playerView.player.ads.schedule(adDescription: adDescription)
    } catch {
      print(error)
    }
  }

  @objc(getCurrentTime:reject:)
  func getCurrentTime(_ resolve: @escaping RCTPromiseResolveBlock, _ reject: @escaping RCTPromiseRejectBlock) {
    return playerView.player.requestCurrentTime() { result, error in
      if error != nil {
        reject(nil, nil, error!)
      } else {
        resolve(result ?? nil)
      }
    }
  }

  @objc
  func setCurrentTime(_ newValue: NSNumber) {
    playerView.player.setCurrentTime(newValue.doubleValue)
  }

  @objc(getDuration:reject:)
  func getDuration(_ resolve: @escaping RCTPromiseResolveBlock, _ reject: @escaping RCTPromiseRejectBlock) {
    resolve(playerView.player.duration)
  }

  @objc(getDurationWithCallback:)
  func getDurationWithCallback(_ callback : @escaping RCTResponseSenderBlock) {
    callback([NSNull(), playerView.player.duration ?? 0]);
  }

  @objc(getPaused:reject:)
  func getPaused(_ resolve: @escaping RCTPromiseResolveBlock, _ reject: @escaping RCTPromiseRejectBlock) {
    resolve(playerView.player.paused)
  }

  @objc(getpreload:reject:)
  func getPreload(_ resolve: @escaping RCTPromiseResolveBlock, _ reject: @escaping RCTPromiseRejectBlock) {
    resolve(playerView.player.preload.rawValue)
  }

  @objc
  func setPreload(_ newValue: NSString) {
    if let preload = Preload(rawValue: newValue as String) {
      playerView.player.setPreload(preload)
    }
  }

  @objc(getPresentationMode:reject:)
  func getPresentationMode(_ resolve: @escaping RCTPromiseResolveBlock, _ reject: @escaping RCTPromiseRejectBlock) {
    resolve(playerView.player.presentationMode.rawValue)
  }

  @objc
  func setPresentationMode(_ newValue: NSString) {
    if let presentationMode = PresentationMode(rawValue: newValue as String) {
      playerView.player.presentationMode = presentationMode
    }
  }

  @objc
  func setSource(_ newValue: [String : Any]) {
    do {
      let data = try JSONSerialization.data(withJSONObject: newValue)
      let sourceDescription = try JSONDecoder().decode(SourceDescription.self, from: data)
      playerView.player.source = sourceDescription
    } catch {
      print(error)
    }
  }

  @objc(getCurrentAds:reject:)
  func getCurrentAds(_ resolve: @escaping RCTPromiseResolveBlock, _ reject: @escaping RCTPromiseRejectBlock) {
    playerView.player.ads.requestCurrentAds{ result, error in
      if error != nil || result == nil {
        reject(nil, nil, error!)
      } else {
        resolve(result!.count)
      }
    }
  }

}
