// TODO (kpshay) Add a BUILD file to ensure this file compiles.
// TODO (nickchavez) Compile this file so it's not readable in framework bundle.

/**
 * Adapter for JSTimer.setTimeout implementation to allow for proper
 * propagation of variadic arguments.
 *
 * @param {function(...)} func The function to invoke.
 * @param {number} delay The amount of milliseconds to wait before invoking the
 *     function.
 * @param {...} args The arguments to pass to the function.
 * @returns {number} The identifier for the timer.
 */
setTimeout = function(func, delay, ...args) {
  return JSTimer.setTimeout(func, delay, args);
};

/**
 * Cancel invocation scheduled by setTimeout (If not yet triggered).
 *
 * @param {number} id The ID returned by setTimeout
 *     for the invocation to cancel.
 */
clearTimeout = function(id) {
  JSTimer.clearTimeout(id);
};

/**
 * Sends a message from the native bridge to Obj-C.
 *
 * @param {string} name The message name.
 * @param {!Object} messageData The message data.
 */
browserlessSender = function(name, messageData) {
  IMAJavaScriptBridge.didReceiveMessage(name, messageData);
};

/**
 * Sends a message from Obj-c to the native bridge.
 *
 * @param {string} name The message name.
 * @param {!Object} messageData The message data.
 */
browserlessReceiver = function(name, messageData) {
  google.ima.NativeBridge.receiveMessage(name, JSON.stringify(messageData));
};

google = {};
google.ima = {};
google.ima.NativeLoader = {};

/**
 * Gets the type of messaging that will be used to send/receive messages from
 * the JavaScript bridge to the native portion of the SDK. Messaging types
 * defined in:
 * javascript/ads/interactivemedia/innerbridge/NativeChannel.js
 *
 * @return {number} The type of messaging used (browserless).
 */
google.ima.NativeLoader.getMessagingType = function() {
  return 3;
};

// Used for platform checks in the native bridge.
navigator = {};

document = {};
/**
 * Temporary stub for getElementsByTagName.
 * TODO (kpshay) Remove once bridged document func is complete.
 * @return {!Array<!Object>} An empty array.
 */
document.getElementsByTagName = function() { return []; };
window = {};
window.location = {};
window.location.search = '';
window.location.hash = '';
window.location.username = '';
window.location.password = '';
window.location.port = '';
window.document = document;
// Simulate a top window context.
window.parent = window;
