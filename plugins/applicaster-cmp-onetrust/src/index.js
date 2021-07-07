import * as React from "react";
import { Text, View, TouchableOpacity, Platform } from "react-native";
import { NativeModules } from "react-native";

import { useNavigation } from "@applicaster/zapp-react-native-utils/reactHooks/navigation";
import Button from "./components/Button";
import { createLogger, addContext } from "./logger";
import { DEFAULT, releaseBuild, parseFontKey} from "./utils";
import { styles, stylesError } from "./styles";

/**
 * Class to present any native screens over QB application
 */

type Props = {
  screenData: {
    general: any,
  },
};

const logger = createLogger();

function renderError(message: string, onDismiss: () => void) {
  logger.warn(message);

  return !releaseBuild ? (
    <View style={stylesError.container}>
      <Text style={stylesError.alert}>⚠️</Text>
      <Text style={stylesError.message}>Could not open native screen:</Text>
      <Text style={stylesError.errorMessage}>{message}</Text>
      <TouchableOpacity style={stylesError.button} onPress={onDismiss}>
        <Text style={stylesError.buttonText}>Dismiss</Text>
      </TouchableOpacity>
    </View>
  ) : (
    <View style={stylesError.container} onLayout={onDismiss}>
      <Text style={stylesError.message}>Could not open native screen</Text>
    </View>
  );
}

export default NativeScreen = ({ screenData }: Props) => {
  const navigator = useNavigation();
  const generalData = screenData?.general;
  const packageName = generalData?.package_name || DEFAULT.packageName;
  const methodName = generalData?.method_name || DEFAULT.methodName;
  const screenPackage = NativeModules?.[packageName];
  const method = screenPackage?.[methodName];
  const showIntroScreen = generalData.show_intro_screen;
  const platformEndpoint = parseFontKey(Platform.OS);

  const {
    intro_button_text: introButtonText,
    [`intro_button_font_${platformEndpoint}`]: introButtonFont,
    intro_button_fontsize: introButtonFontSize,
    intro_button_fontcolor: introButtonFontColor,
    intro_button_backgroundcolor: introBackgroundColor,
    intro_button_focused_fontcolor: introButtonFocusedColor,
    intro_button_focused_backgroundcolor: introButtonFocusedBgColor
  } = generalData;

  const buttonStyle = {
    color: introButtonFontColor,
    fontSize: Number(introButtonFontSize),
    fontFamily: introButtonFont
  };

  const openNativeScreen = async () => {
    addContext({
      manifestData: DEFAULT,
      screenId: screenData.id,
      screenName: screenData.name,
    });

    try {
      const res = await method();
      logger.info(`Received response from native method ${methodName}`, res);
      onDismiss();
    } catch (error) {
      renderError(error);
    }
  }

  const renderIntroScreen = () => {
    return (
      <View style={styles.introContainer}>
        <Button
          label={introButtonText}
          onPress={openNativeScreen}
          textStyle={buttonStyle}
          backgroundColor={introBackgroundColor}
          backgroundButtonUriActive={introButtonFocusedBgColor}
          focusedTextColor={introButtonFocusedColor}
        />
      </View>
    );
  }

  const renderContent = () => {
    if (showIntroScreen) {
      return renderIntroScreen();
    }

    return <View style={styles.container}/>;
  };

  const onDismiss = () => {
    if (showIntroScreen) {
      return;
    }
    // todo: this exit action should be customizible: go back or go home/other screen
    // manifest already has fields set up for this behavior
    if (navigator.canGoBack()) {
      logger.info("Dismissed native screen, going back");
      navigator.goBack();
    } else {
      logger.warn("Dismissed native screen, can't go back, trying to go home");
      navigator.goHome();
    }
  };

  if (!packageName) {
    // warn used that he did somethign wrong
    return renderError(`React package name is not set`, onDismiss);
  }

  if (!methodName) {
    // warn used that he did somethign wrong
    return renderError(`React method name is not set`, onDismiss);
  }

  // todo: handle errors and fire exit action right away after showing some error message for the user

  if (!screenPackage) {
    // warn used that he did somethign wrong
    return renderError(`Package ${packageName} is not found`, onDismiss);
  }

  if (!method) {
    // warn used that he did somethign wrong
    return renderError(
      `Method ${methodName} is not found in the package ${packageName}`,
      onDismiss
    );
  }

  React.useEffect(() => {
    if (!showIntroScreen) {
      openNativeScreen();
    }

    return () => {
      logger.info("Unmounted native screen");
      onDismiss();
    };
  }, []);

  return renderContent();
};
