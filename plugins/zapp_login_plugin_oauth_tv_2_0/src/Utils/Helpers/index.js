import * as R from "ramda";
import { Alert } from "react-native";

export function showAlertLogout(
  success,
  {
    alert_fail_title,
    alert_logout_fail_message,
    alert_succeed_title,
    alert_logout_succeed_message,
  }
) {
  if (success) {
    Alert.alert(alert_succeed_title, alert_logout_succeed_message);
  } else {
    Alert.alert(alert_fail_title, alert_logout_fail_message);
  }
}

export function showAlertLogin(
  success,
  {
    alert_fail_title,
    alert_login_fail_message,
    alert_succeed_title,
    alert_login_succeed_message,
  }
) {
  if (success) {
    Alert.alert(alert_succeed_title, alert_login_succeed_message);
  } else {
    Alert.alert(alert_fail_title, alert_login_fail_message);
  }
}

export function getRiversProp(key, rivers = {}) {
  const getPropByKey = R.compose(
    R.prop(key),
    R.find(R.propEq("type", "zapp_login_plugin_oauth_2_0")),
    R.values
  );

  return getPropByKey(rivers);
}

export const HookTypeData = {
  UNDEFINED: "Undefined",
  PLAYER_HOOK: "PlayerHook",
  SCREEN_HOOK: "ScreenHook",
  USER_ACCOUNT: "UserAccount",
};
