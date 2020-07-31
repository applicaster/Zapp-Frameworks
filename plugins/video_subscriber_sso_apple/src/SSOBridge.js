import { NativeModules } from "react-native";
// eslint-disable-next-line prefer-promise-reject-errors

const nullPromise = () => Promise.reject("SSO module is Null");
const defautVideoSubscriberSSO = {
  requestSSO: nullPromise,
  signOut: nullPromise,
  isSignedIn: nullPromise,
};
const { AppleVideoSubscriberSSO = defautVideoSubscriberSSO } = NativeModules;

const SSOBridge = {
  /**
   * Request SSO procedure
   * @return {Promise<Boolean>} response promise
   */
  requestSSO() {
    try {
      return AppleVideoSubscriberSSO.requestSSO();
    } catch (e) {
      throw e;
    }
  },
  /**
   * Logout from TV provider
   * @return {Promise<Boolean>} response promise
   */
  signOut() {
    try {
      return AppleVideoSubscriberSSO.signOut();
    } catch (e) {
      throw e;
    }
  },

  /**
   * Request if user signed in
   * @return {Promise<Boolean>} response promise
   */
  isSignedIn() {
    try {
      return AppleVideoSubscriberSSO.isSignedIn();
    } catch (e) {
      throw e;
    }
  },
};

export default SSOBridge;
