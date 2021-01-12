import React from "react";
import { StyleSheet } from "react-native";
import Label from "../../Label";
import { mapKeyToStyle } from "../../../../Utils/Customization";
import PropTypes from "prop-types";

const styles = StyleSheet.create({
  container: {
    marginTop: 60,
  },
  text: {
    alignSelf: "center",
    textAlign: "center",
  },
});

const SubscriptionDescription = (props) => {
  const {
    screenStyles,
    payload: { extensions = {} },
  } = props;

  const location = extensions?.event_location;
  const description = extensions?.event_description;
  const title = location || description;

  if (!title) {
    return null;
  }

  const fontStyles = React.useMemo(
    () => mapKeyToStyle("subscription_default_description_text", screenStyles),
    [screenStyles]
  );
  styles.text = React.useMemo(() => [styles.text, fontStyles], []);

  return title ? <Label styles={styles} title={title} /> : null;
};

SubscriptionDescription.propTypes = {
  screenStyles: PropTypes.object,
  payload: PropTypes.object,
};

SubscriptionDescription.defaultProps = {
  payload: {},
  screenStyles: {},
};

export default SubscriptionDescription;
