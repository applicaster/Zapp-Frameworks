import React from 'react';
import {requireNativeComponent} from 'react-native';

const THEOplayerViewNative = requireNativeComponent('THEOplayerView', THEOplayerView);

export default class THEOplayerView extends React.Component {
    render() {
        return <THEOplayerViewNative
            {...this.props}
        />;
    }
}
