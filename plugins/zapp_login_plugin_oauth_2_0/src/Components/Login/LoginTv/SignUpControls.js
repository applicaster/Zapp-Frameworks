import React from "react";
import * as R from "ramda";
import { View } from "react-native";
import PropTypes from "prop-types";

import { FocusableGroup } from "@applicaster/zapp-react-native-ui-components/Components/FocusableGroup";

import { mapKeyToStyle } from "../../../Utils/Customization";
import Button from "../../UIComponents/Buttons/FocusableButton";

const groupId = "signup-button";

const SignUpControls = ({ screenStyles, onPress, style, screenLocalizations }) => {
  const buttonTextStyles = React.useMemo(
    () => mapKeyToStyle("signup_action_button", screenStyles),
    []
  );

  return (
    <FocusableGroup id={groupId} shouldUsePreferredFocus isParallaxDisabled>
      <View style={style}>
        <Button
          {...{
            groupId,
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
    </FocusableGroup>
  );
};
SignUpControls.propTypes = {
  style: PropTypes.object,
  onPress: PropTypes.func,
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
  screenLocalizations: {},
};

export default SignUpControls;
