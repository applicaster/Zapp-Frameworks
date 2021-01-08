import Foundation

@objc(ReactNativeEventEmitter)
class ReactNativeEventEmitter: RCTEventEmitter {

  var hasListeners : Bool = false

  // All Events which must be support by React Native.
  var allEvents: [String] = []

  override init() {
    super.init()
    print("ReactNativeEventEmitter init")
    EventEmitter.sharedInstance.registerEventEmitter(eventEmitter: self)
  }

  // Override implementation of queue setup
  // - Returns: when true class initialized on the main thread,
  //            when false class initialized on a background thread
  @objc
  override static func requiresMainQueueSetup() -> Bool {
    return true;
  }

  // Base override for RCTEventEmitter.
  //
  // - Returns: all supported events
  @objc open override func supportedEvents() -> [String] {
    return allEvents
  }

  // Will be called when this module's first listener is added.
  override func startObserving() {
    print("ReactNativeEventEmitter startObserving")

    hasListeners = true

    super.startObserving()

  }

  // Will be called when this module's last listener is removed, or on dealloc.
  override func stopObserving() {
    print("ReactNativeEventEmitter stopObserving")

    hasListeners = false

    EventEmitter.sharedInstance.removeAllEventListeners()
    allEvents = []

    super.stopObserving()

  }

  override func addListener(_ eventName: String!) {
    print("ReactNativeEventEmitter addListener: ", eventName)

    if EventEmitter.sharedInstance.addEventListener(eventName: eventName) {
      allEvents.append(eventName)
    }

    super.addListener(eventName)
  }

}
