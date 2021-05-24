import * as React from "react";
import { View, Text, Dimensions, Image } from "react-native";

class IconWithTitle extends React.Component {
  render() {
    const {
      imgUrl,
      imgSize = 130,
      containerSize = 240,
      title
    } = this.props
    return (
      <View style={{...styles.container, width: containerSize}}>
        <Image
          style={{ width: imgSize, height: imgSize }}
          resizeMode="contain"
          source={{ uri: imgUrl }}
        />
        <Text style={styles.title}>{title}</Text>
      </View>
    );
  }
}

const styles = {
  container: {
    justifyContent: 'center',
    alignItems: 'center'
  },
  title: {
    fontSize: 24,
    color: "#525A5C",
    marginTop: 25,
  }
};

IconWithTitle.displayName = 'IconWithTitle';
export default IconWithTitle;