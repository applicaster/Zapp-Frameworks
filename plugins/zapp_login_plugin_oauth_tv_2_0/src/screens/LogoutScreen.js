import React, { useEffect, useRef, useState } from "react";
import axios from "axios";
import { View, Text, Platform } from "react-native";
import { useInitialFocus } from "@applicaster/zapp-react-native-utils/focusManager";
import { localStorage } from "@applicaster/zapp-react-native-bridge/ZappStorage/LocalStorage";
import Button from "../Components/Button";
import Layout from "../Components/Layout";

const LogoutScreen = (props) => {
  const {
    segmentKey,
    name,
    namespace,
    token,
    gygiaLogoutUrl,
    groupId,
    parentFocus,
    focused,
    goToScreen,
    forceFocus,
    accountUrl,
  } = props;

  const [userName, setUserName] = useState("");
  const [accessToken, setAccessToken] = useState("");

  const signoutButton = useRef(null);

  useEffect(() => {
    getAccessData();
  }, []);

  const getAccessData = async () => {
    const userName = await localStorage
      .getItem(name, namespace)
      .catch((err) => console.log(err, name));
    const accessToken = await localStorage
      .getItem(token, namespace)
      .catch((err) => console.log(err, name));
    setUserName(userName);
    setAccessToken(accessToken);
    if (forceFocus) {
      goToScreen(null, false, true);
    }
  };

  const handleSignOut = () => {
    axios
      .post(
        `${gygiaLogoutUrl}`,
        {
          access_token: accessToken,
        },
        {
          headers: {
            accept: "application/json",
            "Content-Type": "application/json",
          },
        }
      )
      .then(async (res) => {
        if (res.data.succeeded) {
          localStorage.setItem(token, "NOT_SET", namespace);
          goToScreen("INTRO", true);
        }
      })
      .catch((err) => console.log(err));
  };

  if (Platform.OS === "android") {
    useInitialFocus(forceFocus || focused, signoutButton);
  }

  return (
    <Layout>
      <View style={styles.container}>
        <Text style={styles.text}>
          Hi <Text style={styles.userName}>{userName || userName}!</Text>
        </Text>
        <Text style={styles.text}>
          To update your account please visit{" "}
          <Text style={styles.url}>{accountUrl}</Text>
        </Text>
        <Button
          label="Sign Out"
          onPress={() => handleSignOut()}
          preferredFocus={true}
          groupId={groupId}
          style={styles.buttonContainer}
          buttonRef={signoutButton}
          id={"sign-out-button"}
          nextFocusLeft={parentFocus ? parentFocus.nextFocusLeft : null}
        />
      </View>
    </Layout>
  );
};

const styles = {
  container: {
    flex: 1,
    alignItems: "flex-start",
    marginTop: 100,
  },
  text: {
    color: "#525A5C",
    fontSize: 32,
    marginBottom: 20,
  },
  userName: {
    fontWeight: "bold",
    fontSize: 36,
    marginBottom: 60,
    color: "#525A5C",
  },
  url: {
    fontWeight: "bold",
    fontSize: 36,
    marginBottom: 60,
    color: "#525A5C",
  },
  subTitle: {
    color: "#525A5C",
    fontSize: 32,
  },
  buttonContainer: {
    marginTop: 80,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    alignSelf: "center",
  },
};

LogoutScreen.displayName = "LogoutScreens";
export default LogoutScreen;
