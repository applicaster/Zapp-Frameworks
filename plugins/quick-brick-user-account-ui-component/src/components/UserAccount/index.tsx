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
const logger = componentsLogger.addSubsystem(
  "quick-brick-toggle-plugin-lifecycle"
);

type Props = {
  component: {
    id: string;
    styles: {
      toggle_background_color: string;
    };
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
    flexDirection: "row",
    backgroundColor: "red",
    height: 70,
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

  //   const { component, onLoadFinished } = props;
  //   const { data, localizations, styles, id } = component;

  //   const {
  //     test = "Test",
  //   } = useLocalizedStrings({
  //     localizations,
  //   });
  //   const pluginIdentifier = data?.plugin_identifier;

  //   const { test_background_color } = styles;

  console.log({ theme });
  React.useEffect(() => {}, []);

  return (
    <View style={newContainerStyleStyle}>
      {/* <AccountInfo />
      <Button />
      <Button /> */}
    </View>
  );
}
