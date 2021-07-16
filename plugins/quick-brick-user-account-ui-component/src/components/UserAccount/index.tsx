import * as React from "react";
import * as R from "ramda";
import {
  View,
  TouchableHighlight,
  StyleSheet,
  Text,
  Alert,
} from "react-native";
import { pluginsManagerBridge } from "@applicaster/zapp-react-native-bridge/PluginManager";
import { componentsLogger } from "@applicaster/zapp-react-native-ui-components/Helpers/logger";
// import { handleStyleType } from "./Utils";
import { platformSelect } from "@applicaster/zapp-react-native-utils/reactUtils";
import { useTheme } from "@applicaster/zapp-react-native-utils/theme";
import { useLocalizedStrings } from "@applicaster/zapp-react-native-utils/localizationUtils";
import { AccountInfo } from "../AccountInfo";
import { Button } from "../Button";
import { UserPhoto } from "../UserPhoto";
import {
  styleForLogin1Button,
  styleForLogin2Button,
  styleForLogoutButton,
} from "./Utils";
const logger = componentsLogger.addSubsystem(
  "quick-brick-toggle-plugin-lifecycle"
);

type Props = {
  component: {
    id: string;
    styles: GeneralStyles;
    data: {
      plugin_identifier: string;
    };
    localizations: {};
  };
  onLoadFinished: any;
};

const componentStyles = StyleSheet.create({
  containerStyle: {
    flex: 1,
    // flexDirection: "row",
    backgroundColor: "#161b29FF",
    alignItems: "center",
    justifyContent: "center",
  },
});

export function UserAccount(props: Props) {
  //   const [enabled, setEnabled] = React.useState(null);
  const theme = useTheme();

  const newContainerStyleStyle = {
    ...componentStyles.containerStyle,
    paddingLeft: theme?.component_padding_left,
    paddingRight: theme?.component_padding_right,
    paddingBottom: theme?.component_margin_bottom,
  };

  const { component, onLoadFinished } = props;
  const { data, localizations, styles, id } = component;
  console.log({ data, localizations, styles, id });
  const {
    account_title = "Account",
    user_name_title = "User",
    subscription_title = "Subscription",
    subscription_expiration_title = "- renews",
    logout_title_text = "Logout",
    login_button_1_title_text = "Login 1",
    login_button_2_title_text = "Login 2",
  } = useLocalizedStrings({
    localizations,
  });

  const pluginIdentifier = data?.plugin_identifier;

  React.useEffect(() => {
    onLoadFinished();
  }, []);

  const styleLogin1Button = React.useCallback(
    () => styleForLogin1Button(styles),
    [styles]
  );

  const styleLogin2Button = React.useCallback(
    () => styleForLogin2Button(styles),
    [styles]
  );

  const onLogin1 = React.useCallback(() => {}, []);
  const onLogin2 = React.useCallback(() => {}, []);
  const onLogout = React.useCallback(() => {}, []);

  return (
    <View style={newContainerStyleStyle}>
      <UserPhoto imageSrc={styles?.user_image_placeholder} />
      {/* <AccountInfo /> */}
      <Button
        styles={styleLogin1Button()}
        id={"login_1"}
        onPress={onLogin1}
        titleText={login_button_1_title_text}
      />
      <Button
        styles={styleLogin2Button()}
        id={"login_2"}
        onPress={onLogin2}
        titleText={login_button_2_title_text}
      />
    </View>
  );
}
