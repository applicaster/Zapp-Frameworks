import React from 'react';
import { Alert, Button, Dimensions, NativeModules, StyleSheet, Text, View, Platform, ScrollView } from 'react-native';
import THEOplayerView from './THEOplayerView'
import THEOeventEmitter from './TheoEventEmitter'

const theoEventEmitter = new THEOeventEmitter();

export default class TheoPlayerViewScreen extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            paused: true,
            playPauseButtonTitle: "Play",
            duration: undefined,
            currentTime: undefined
        };

        this.listeners = {};
    }

    togglePlayPause = () => {
        if (this.state.paused) {
            NativeModules.THEOplayerViewManager.play();
        } else {
            NativeModules.THEOplayerViewManager.pause();
        }
    };

    updatePausedState = (paused) => {
        let state = this.state;
        state.paused = paused;
        state.playPauseButtonTitle = paused ? "Play" : "Pause";
        this.setState(state);
    };

    componentDidMount() {
        this.listeners['durationchange'] = theoEventEmitter.addListener('durationchange', (event) => {
            let state = this.state;
            state.duration = event.duration;
            this.setState(state);
        }
        );

        this.listeners['timeupdate'] = theoEventEmitter.addListener('timeupdate', (event) => {
            let state = this.state;
            state.currentTime = event.currentTime;
            this.setState(state);
        }
        );
    }

    render() {
        let drmExampleSourceConfiguration = null;
        /*
          Problem on android fullscreen change with theoplayer scaling when ScrollView component is set
        */
        let BaseComponent = View;

        /*
          If there are scaling issues during the change of the fullscreen remove 'aspectRatio' & set player height
        */
        let playerStyle = {
            ...styles.player,
        };

        if (Platform.OS === 'android') {
            playerStyle.width = Math.floor(Dimensions.get('window').width);
            drmExampleSourceConfiguration = {
                sources: [{
                  type: 'application/dash+xml',
                  src: 'https://wvm.ezdrm.com/demo/stream.mpd',
                  drm: {
                      widevine: {
                          licenseAcquisitionURL: "https://widevine-dash.ezdrm.com/proxy?pX=BF9CEB"
                      },
                  }
                }],
                poster: 'https://cdn.theoplayer.com/video/big_buck_bunny/poster.jpg',
            }
        } else {
            BaseComponent = ScrollView;
            drmExampleSourceConfiguration = {
                sources: [{
                    src: "https://fps.ezdrm.com/demo/video/ezdrm.m3u8",
                    type: "application/x-mpegurl",
                    drm: {
                        integration: 'ezdrm',
                        fairplay: {
                        	licenseAcquisitionURL: "https://fps.ezdrm.com/api/licenses/09cc0377-6dd4-40cb-b09d-b582236e70fe",
                            certificateURL: "https://fps.ezdrm.com/demo/video/eleisure.cer"
                        }
                    }

                }],
            }
        }

        return (
          <BaseComponent style={styles.containerBase}>
              <View style={styles.container}>
                  <THEOplayerView
                      style={playerStyle}
                      fullscreenOrientationCoupling={true}
                      autoplay={true}
                      onSeek={(e) => {
                          console.log('Seek changed: ' + JSON.stringify(e.nativeEvent))
                      }}
                      onPause={(e) => {
                          this.updatePausedState(true)
                      }}
                      onPlay={(e) => {
                          this.updatePausedState(false)
                      }}
                      source={
                          {
                              sources: [{
                                  type: 'application/x-mpegurl',
                                  src: 'https://cdn.theoplayer.com/video/big_buck_bunny/big_buck_bunny.m3u8',
                              }],
                              poster: 'https://cdn.theoplayer.com/video/big_buck_bunny/poster.jpg',
                          }
                      }
                  />

                  <View style={styles.controlsContainer}>
                      <Button style={styles.playPause}
                          onPress={this.togglePlayPause}
                          title={this.state.playPauseButtonTitle} />
                      <Text style={styles.currentTimeDuration}>{this.state.currentTime}/{this.state.duration}</Text>
                  </View>

                  <View style={styles.buttonContainer}>
                      <Button style={styles.button}
                          onPress={async () => {
                              NativeModules.THEOplayerViewManager.setSource(
                                  {
                                      sources: [{
                                          type: 'application/x-mpegurl',
                                          src: 'https://cdn.theoplayer.com/video/big_buck_bunny/big_buck_bunny.m3u8'
                                      }],
                                      poster: 'https://cdn.theoplayer.com/video/big_buck_bunny/poster.jpg'
                                  }
                              );
                          }}
                          title="Set source"
                      />
                      <Button style={styles.button}
                          onPress={async () => {
                              NativeModules.THEOplayerViewManager.setSource(
                                  {
                                      sources: [{
                                          src: "https://cdn.theoplayer.com/video/big_buck_bunny/big_buck_bunny.m3u8",
                                          type: "application/x-mpegurl",
                                      }],
                                      poster: 'https://cdn.theoplayer.com/video/big_buck_bunny/poster.jpg',
                                      ads: [
                                          {
                                              sources: "https://cdn.theoplayer.com/demos/preroll.xml",
                                              timeOffset: "start"
                                          }
                                      ]
                                  }
                              );
                          }}
                          title="Set ad source"
                      />
                      <Button style={styles.button}
                          onPress={async () => {
                              NativeModules.THEOplayerViewManager.setSource(drmExampleSourceConfiguration);
                          }}
                          title="Set drm source"
                      />
                      <Button style={styles.button}
                          onPress={() => {
                              NativeModules.THEOplayerViewManager.stop();
                          }}
                          title="Stop"
                      />
                      <Button style={styles.button}
                          onPress={() => {
                              NativeModules.THEOplayerViewManager.setCurrentTime(50);
                          }}
                          title="Set Current Time"
                      />
                      <Button style={styles.button}
                          onPress={async () => {
                              const currentTime = await NativeModules.THEOplayerViewManager.getCurrentTime();
                              console.log(currentTime);
                          }}
                          title="Get Current Time"
                      />
                      <Button style={styles.button}
                          onPress={async () => {
                              const duration = await NativeModules.THEOplayerViewManager.getDuration();
                              Alert.alert('Duration: ' + duration);
                          }}
                          title="Duration with Promise"
                      />
                      <Button style={styles.button}
                          onPress={() => {
                              if (Platform.OS === 'ios') {
                                  NativeModules.THEOplayerViewManager.getDurationWithCallback((error, duration) => {
                                      Alert.alert('Duration ios: ' + duration);
                                  });
                              } else {
                                  NativeModules.THEOplayerViewManager.getDurationWithCallback((error) => {
                                      console.log(msg);
                                  },
                                      (duration) => {
                                          Alert.alert('Duration android: ' + duration);
                                      });
                              }

                          }}
                          title="Duration with Callback"
                      />
                      <Button style={styles.button}
                          onPress={async () => {
                              const currentAds = await NativeModules.THEOplayerViewManager.getCurrentAds();
                              console.log(currentAds + " ad(s) currently active.");
                          }}
                          title="Get current ads"
                      />
                      <Button style={styles.button}
                          onPress={() => {
                              NativeModules.THEOplayerViewManager.scheduleAd({
                                  sources: "//cdn.theoplayer.com/demos/preroll.xml",
                                  timeOffset: "start"
                              });
                          }}
                          title="Schedule an ad"
                      />
                      <Button style={styles.button}
                          onPress={() => {
                              if (!this.listeners['play']) {
                                  this.listeners['play'] = theoEventEmitter.addListener(
                                      'play',
                                      (event) => console.log('Play EVENT: ' + JSON.stringify(event))
                                  );
                              }
                          }}
                          title="Add PLAY event listener"
                      />
                      <Button style={styles.button}
                          onPress={() => {
                              if (this.listeners['play']) {
                                  this.listeners['play'].remove();
                                  delete this.listeners['play'];
                                  console.log("Play event listener removed.")
                              }
                          }}
                          title="Remove PLAY event listener"
                      />
                  </View>
              </View>
          </BaseComponent>
        );
    }

    componentWillUnmount() {
        Object.keys(this.listeners).forEach(key => {
            this.listeners[key].remove()
        })

        NativeModules.THEOplayerViewManager.destroy();
    }
}

const styles = StyleSheet.create({
    containerBase: {
        flex: 1,
    },

    container: {
        flex: 1,
    },

    player: {
        backgroundColor: "black",
        aspectRatio: 1.7,
    },

    controlsContainer: {
        height: 50,
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        backgroundColor: 'black'
    },

    playPause: {
        width: 100,
        margin: 8,
        color: 'black',
        backgroundColor: 'white'
    },

    currentTimeDuration: {
        width: '50%',
        margin: 8,
        marginTop: 12,
        color: 'white',
        textAlign: 'right'
    },

    buttonContainer: {
        flex: 1,
        flexWrap: 'wrap',
        flexDirection: 'row',
        justifyContent: 'space-around'
    },

    button: {
        flex: 1
    }
});
