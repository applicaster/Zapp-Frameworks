import React from "react";
import * as R from "ramda";
import { View } from "react-native";
import PropTypes from "prop-types";

import { mapKeyToStyle } from "../../../Utils/Customization";
import Button from "../../UIComponents/Buttons/FocusableButton";
import { useInitialFocus } from "@applicaster/zapp-react-native-utils/focusManager";

const SignUpControls = ({
  screenStyles,
  onPress,
  style,
  focused,
  parentFocus,
  screenLocalizations,
}) => {
  const buttonRef = React.useRef(null);

  useInitialFocus(focused, buttonRef);

  const buttonTextStyles = React.useMemo(
    () => mapKeyToStyle("signup_action_button", screenStyles),
    []
  );

  return (
    <View style={style}>
      <Button
        ref={buttonRef}
        {...{
          focused,
          ...parentFocus,
          label: screenLocalizations.action_button_signup_text,
          onPress,
          backgroundColor: screenStyles.signup_action_button_background,
          backgroundColorFocused: screenStyles.signup_action_button_background_focused,
          textColorFocused: screenStyles.signup_action_button_fontcolor_focused,
          textStyles: buttonTextStyles,
          borderRadius: screenStyles.signup_action_button_border_radius,
        }}
      />
    </View>
  );
};
SignUpControls.propTypes = {
  style: PropTypes.object,
  onPress: PropTypes.func,
  focused: PropTypes.bool,
  parentFocus: PropTypes.object,
  screenStyles: PropTypes.shape({
    signup_action_button_background: PropTypes.string,
    signup_action_button_background_focused: PropTypes.string,
    signup_action_button_fontcolor_focused: PropTypes.string,
    signup_action_button_border_radius: PropTypes.number,
  }),
  screenLocalizations: PropTypes.shape({
    action_button_signup_text: PropTypes.string,
  }),
};

SignUpControls.defaultProps = {
  style: {},
  screenStyles: {},
  onPress: R.identity,
  parentFocus: {},
  screenLocalizations: {},
};

export default SignUpControls;
