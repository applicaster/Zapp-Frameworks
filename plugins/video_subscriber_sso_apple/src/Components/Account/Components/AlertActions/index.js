import { Alert, Linking, Platform } from "react-native";

export function presentLogoutAlert(styles, plugin, navigator) {
  const {
    sign_out_alert_title,
    sign_out_alert_ok_button_title,
    sign_out_alert_message,
    sign_out_settings_path_tvos,
    sign_out_settings_path_ios,
    sign_out_alert_settings_button_title,
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
    failure_alert_title,
    failure_alert_description,
    failure_alert_cancel_button_title,
    failure_alert_login_applicaster_button_title,
    failure_alert_settings_button_title,
  } = styles;

  Alert.alert(
    failure_alert_title,
    failure_alert_description,
    [
      {
        text: failure_alert_cancel_button_title,
        style: "cancel",
      },
      {
        text: failure_alert_login_applicaster_button_title,
        onPress: () => {
          navigator.push(plugin);
        },
      },
      {
        text: failure_alert_settings_button_title,
        onPress: () => Linking.openURL("app-settings:"),
      },
    ],
    { cancelable: false }
  );
}
