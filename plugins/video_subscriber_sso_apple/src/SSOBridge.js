import { NativeModules } from "react-native";
// eslint-disable-next-line prefer-promise-reject-errors

const nullPromise = () => Promise.reject("SSO module is Null");
const defautVideoSubscriberSSO = {
  signIn: nullPromise,
  signOut: nullPromise,
  isSignedIn: nullPromise,
};
const { AppleVideoSubscriberSSO = defautVideoSubscriberSSO } = NativeModules;

const SSOBridge = {
  /**
   * Sign in to TV provider
   * @return {Promise<Boolean>} response promise
   */
  signIn() {
    return AppleVideoSubscriberSSO.signIn();
  },
  /**
   * Logout from TV provider
   * @return {Promise<Boolean>} response promise
   */
  signOut() {
    return AppleVideoSubscriberSSO.signOut();
  },

  /**
   * Request if user signed in
   * @return {Promise<Boolean>} response promise
   */
  isSignedIn() {
    return AppleVideoSubscriberSSO.isSignedIn();
  },
};

export default SSOBridge;
