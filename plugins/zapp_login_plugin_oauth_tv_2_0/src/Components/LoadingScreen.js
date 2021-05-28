import * as React from "react";
import { ActivityIndicator, Dimensions, View } from "react-native";

const { width, height } = Dimensions.get('window');

class LoadingScreen extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <View style={styles.container}>
        <ActivityIndicator size="large" color="#525A5C" />
      </View>
    );
  }
}

const styles = {
  container: {
    width,
    height,
    alignItems: 'center',
    justifyContent: 'center',
    flexDirection: 'row',
  },
};

LoadingScreen.displayName = 'LoadingScreen';
export default LoadingScreen;
