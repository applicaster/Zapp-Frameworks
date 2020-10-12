const reactNative = jest.genMockFromModule("react-native");

reactNative.NativeModules = {};

function __addNativeModule(name, mock) {
  reactNative.NativeModules[name] = mock;
}

function __removeNativeModule(name) {
  delete reactNative.NativeModules[name];
}

function __resetNativeModules() {
  reactNative.NativeModules = {};
}

reactNative.__addNativeModule = __addNativeModule;
reactNative.__removeNativeModule = __removeNativeModule;
reactNative.__resetNativeModules = __resetNativeModules;

module.exports = reactNative;
