import { Alert, Linking, Platform } from "react-native";

export function presentLogoutAlert(styles, plugin, navigator) {
  const {
    sign_out_alert_title = "SignOut",
    sign_out_alert_ok_button_title = "Ok",
    sign_out_alert_message = "The app was authenticated through Apple TV Provider Authenticaiton. \nTo Sign Out please navigate to the device Settings App. \n",
    sign_out_settings_path_tvos = "Settings > Users and Accounts > TV Provider > Sign Out",
    sign_out_settings_path_ios = "Settings > TV Provider > Sign Out",
    sign_out_alert_settings_button_title = "Open TV Providers",
  } = styles;

  const isIOS13 = parseInt(Platform.Version, 10);

  let settingsMessage = sign_out_settings_path_ios;

  if (Platform.isTV) {
    settingsMessage = sign_out_settings_path_tvos;
  }

  let message = `${sign_out_alert_message}${settingsMessage}`;

  let buttons = [
    {
      text: sign_out_alert_ok_button_title,
      style: "cancel",
    },
  ];

  if (isIOS13 >= 13) {
    const settingButton = {
      text: sign_out_alert_settings_button_title,
      onPress: () => Linking.openURL("prefs-tvprovider:"),
    };

    buttons.push(settingButton);
  }

  Alert.alert(sign_out_alert_title, message, buttons, { cancelable: false });
}

export function presentLoginFailAlert(styles, plugin, navigator) {
  const {
    failure_alert_title = "Unable to connect to TV Provider",
    failure_alert_description = "Please make sure TV Provider is configured in the device settings. As alternative you can login with Applicaster provider.",
    failure_alert_cancel_button_title = "Cancel",
    failure_alert_login_applicaster_button_title = "Login with Applicaster",
    failure_alert_settings_button_title = "Open app settings",
  } = styles;

  let buttons = [
    {
      text: failure_alert_cancel_button_title,
      style: "cancel",
    },

    {
      text: failure_alert_settings_button_title,
      onPress: () => Linking.openURL("app-settings:"),
    },
  ];

  if (plugin) {
    buttons.push({
      text: failure_alert_login_applicaster_button_title,
      onPress: () => {
        navigator.push(plugin);
      },
    });
  }

  Alert.alert(failure_alert_title, failure_alert_description, buttons, {
    cancelable: false,
  });
}
