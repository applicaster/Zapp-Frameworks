import React, { Component } from "react";
import { TVEventHandlerComponent } from "@applicaster/zapp-react-native-tvos-ui-components/Components/TVEventHandlerComponent";
import { Dimensions, View, Image } from "react-native";

const noop = () => null;
const { height } = Dimensions.get("window");

class Layout extends Component {
  render() {
    const {
      background_color,
      background_color_prehook,
      client_logo,
    } = this.props.screenStyles;

    return (
      <TVEventHandlerComponent
        tvEventHandler={this.props.tvEventHandler || noop}
      >
        <View
          style={{
            ...styles.container,
            backgroundColor: this.props.isPrehook
              ? background_color
              : background_color_prehook,
          }}
        >
          {this.props.isPrehook && (
            <View style={styles.logoContainer}>
              <Image
                style={styles.logo}
                resizeMode="contain"
                source={{
                  uri: client_logo,
                }}
              />
            </View>
          )}
          <View style={styles.subContainer}>{this.props.children}</View>
        </View>
      </TVEventHandlerComponent>
    );
  }
}

const styles = {
  container: {
    flex: 1,
    height,
    alignItems: "center",
  },
  logoContainer: {
    width: 150,
    height: 150,
    paddingLeft: 100,
    paddingTop: 50,
    alignSelf: "flex-start",
  },
  subContainer: {
    flex: 1,
    width: 1390,
    alignItems: "center",
    justifyContent: "center",
    paddingTop: 100,
  },
  logo: {
    width: 150,
    height: 150,
  },
};

Layout.displayName = "Layout";
export default Layout;
