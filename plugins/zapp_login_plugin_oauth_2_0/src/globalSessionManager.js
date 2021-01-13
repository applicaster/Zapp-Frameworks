import * as R from "ramda";
//  Remember to set isLoggedIn to false and clear time when adding logOut feature.

const globalSessionManager = {
  setSession: () => {
    global.devDemoLogin = {
      isLoggedIn: false,
      timer: false
    };
  },

  resetTimer: expiresInSeconds => {
    const timer = R.path(["devDemoLogin", "timer"])(global);
    if (timer) {
      clearTimeout(timer);
    }

    global.devDemoLogin.timer = setTimeout(() => {
      global.devDemoLogin.isLoggedIn = false;
    }, expiresInSeconds * 1000);
  },

  logIn: credentials => {
    global.devDemoLogin = {
      isLoggedIn: true
    };
    // Session should be set before logging in.
    globalSessionManager.resetTimer(credentials.expiresIn);
  },

  logOut: () => {
    const timer = R.path(["devDemoLogin", "timer"])(global);
    global.devDemoLogin = {
      ...global.devDemoLogin,
      isLoggedIn: false
    };
    timer && clearTimeout(timer);
  }
};

export default globalSessionManager;
