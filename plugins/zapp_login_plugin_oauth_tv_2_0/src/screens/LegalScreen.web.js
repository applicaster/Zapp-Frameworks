import React, { useEffect, useRef } from "react";
import { View, Platform, Text } from "react-native";
import { useInitialFocus } from "@applicaster/zapp-react-native-utils/focusManager";
import { trackEvent } from "../analytics/segment/index";
import parse, { domToReact } from "html-react-parser";
import Button from "../components2/Button";
import Layout from "../components2/Layout";

const parseOptions = {
  replace: ({ name, children }) => {
    if (name === "h1") {
      return (
        <View style={{ marginBottom: 30 }}>
          <Text style={styles.title}>{domToReact(children)}</Text>
        </View>
      );
    }

    if (name === "h3") {
      return (
        <View style={{ marginBottom: 30 }}>
          <Text style={styles.text}>
            {domToReact(children)}
            {"\n"}
          </Text>
        </View>
      );
    }
  },
};

const LegalScreen = (props) => {
  const { segmentKey, isPrehook, groupId, goToScreen, legalContent } = props;

  const legalButton = useRef(null);

  useEffect(() => {
    trackEvent("Legal Section");
  }, []);

  if (Platform.OS === "android") {
    useInitialFocus(true, legalButton);
  }

  return (
    <Layout isPrehook={isPrehook}>
      <View style={styles.container}>
        <View style={styles.legalSection}>
          {parse(`<div>${legalContent}</div>`, parseOptions)}
        </View>
        <View style={styles.buttonContainer}>
          <Button
            label="Ok"
            onPress={() => goToScreen("INTRO")}
            preferredFocus={true}
            groupId={groupId}
            style={styles.focusContainer}
            buttonRef={legalButton}
            id={"legal-button"}
          />
        </View>
      </View>
    </Layout>
  );
};

const styles = {
  container: {
    flex: 1,
    alignItems: "center",
    marginTop: 0,
  },
  legalSection: {
    width: "100%",
    height: 550,
  },
  title: {
    color: "#525A5C",
    fontSize: 42,
    fontWeight: "bold",
  },
  text: {
    color: "#525A5C",
    fontSize: 20,
  },
  buttonContainer: {
    width: "100%",
    height: 200,
    alignItems: "center",
    justifyContent: "center",
  },
  focusContainer: {
    marginTop: 40,
    justifyContent: "center",
    alignItems: "center",
  },
};

LegalScreen.displayName = "LegalScreen";
export default LegalScreen;
