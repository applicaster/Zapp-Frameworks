import React from "react";
import { StyleSheet } from "react-native";
import Label from "../../Label";
import { mapKeyToStyle } from "../../../../Utils/Customization";
import PropTypes from "prop-types";

const styles = StyleSheet.create({
  container: {
    marginTop: 30,
    marginLeft: 150,
    marginRight: 150,
  },
  text: {
    alignSelf: "center",
    textAlign: "center",
  },
});

const PolicyAgreementTitle = (props) => {
  const {
    screenStyles,
    screenLocalizations,
  } = props;

  const fontStyles = React.useMemo(
    () => mapKeyToStyle("policy_agreement_text", screenStyles),
    [screenStyles]
  );
  styles.text = React.useMemo(() => [styles.text, fontStyles], []);
  return <Label styles={styles} title={screenLocalizations.policy_agreement_text} />;
};

PolicyAgreementTitle.propTypes = {
  screenStyles: PropTypes.object,
  screenLocalizations: PropTypes.shape({
    policy_agreement_text: PropTypes.string
  }),
};

PolicyAgreementTitle.defaultProps = {
  screenStyles: {},
  screenLocalizations: {},
};

export default PolicyAgreementTitle;
