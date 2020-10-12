import * as React from "react";
import { View, Text } from "react-native";

type Props = {
  name: string;
};

export function SayMyName({ name }: Props) {
  return (
    <View>
      <Text>{name}</Text>
    </View>
  );
}

export class ClassSayMyName extends React.Component<Props> {
  render() {
    return (
      <View>
        <Text>{this.props.name}</Text>
      </View>
    );
  }
}
