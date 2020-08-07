import { Alert, Linking } from "react-native";


export function presentAlert(styles) {
    const {
        failure_alert_title,
        failure_alert_description,
        failure_alert_cancel_button_title,
        failure_alert_login_applicaster_button_title,
        failure_alert_settings_button_title
    } = styles
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

