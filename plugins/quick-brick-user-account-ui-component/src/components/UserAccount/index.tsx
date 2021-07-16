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
  getStylesForTitleLabel,
  getStylesForDescriptionLabel,
} from "./Utils";
import { login, logout, getUserId, getSubscriptionData } from "../../mockData";

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
    backgroundColor: "#161b29FF",
    alignItems: "center",
    justifyContent: "center",
  },
});

export function UserAccount(props: Props) {
  const [isLogedIn, setIsLogedIn] = React.useState(false);
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

  const styleLogoutButton = React.useCallback(
    () => styleForLogoutButton(styles),
    [styles]
  );

  const styleTitleLabel = React.useCallback(
    () => getStylesForTitleLabel(styles),
    [styles]
  );

  const styleDescriptionLabel = React.useCallback(
    () => getStylesForDescriptionLabel(styles),
    [styles]
  );

  const accoutInfoStyles = {
    logoutButtonStyles: styleLogoutButton(),
    labelStyles: {
      title_style: styleTitleLabel(),
      description_style: styleDescriptionLabel(),
    },
  };
  const accountTitles = {
    account_title,
    user_name_title: getUserId(user_name_title),
    subscription_title,
    subscription_expiration_title: getSubscriptionData(
      subscription_expiration_title
    ),
    logout_title_text,
  };

  const onLogin1 = React.useCallback(async () => {
    const result = await login();
    if (result) {
      setIsLogedIn(true);
    }
  }, []);
  const onLogin2 = React.useCallback(async () => {
    const result = await login();
    if (result) {
      setIsLogedIn(true);
    }
  }, []);
  const onLogout = React.useCallback(async () => {
    const result = await logout();
    if (result) {
      setIsLogedIn(false);
    }
  }, []);

  const customContainerStyle = {
    height: 32,
    marginRight: 57,
    marginLeft: 57,
    marginBottom: 12,
  };

  function renderLoginFlow() {
    return (
      <>
        <UserPhoto imageSrc={styles?.user_image_placeholder} />
        <Button
          customContainerStyle={customContainerStyle}
          styles={styleLogin1Button()}
          id={"login_1"}
          onPress={onLogin1}
          titleText={login_button_1_title_text}
        />
        <Button
          customContainerStyle={customContainerStyle}
          styles={styleLogin2Button()}
          id={"login_2"}
          onPress={onLogin2}
          titleText={login_button_2_title_text}
        />
      </>
    );
  }
  return (
    <View style={newContainerStyleStyle}>
      {isLogedIn ? (
        <AccountInfo
          onLogoutPress={onLogout}
          user_image_placeholder={styles?.user_image_placeholder}
          styles={accoutInfoStyles}
          titles={accountTitles}
        />
      ) : (
        renderLoginFlow()
      )}
    </View>
  );
}
