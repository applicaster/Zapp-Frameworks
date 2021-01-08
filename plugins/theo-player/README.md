## Video AppleTV

### Configurable props
* [allowsExternalPlayback](#allowsexternalplayback)
* [audioOnly](#audioonly)
* [bufferConfig](#bufferconfig)
* [controls](#controls)
* [filter](#filter)
* [fullscreen](#fullscreen)
* [fullscreenAutorotate](#fullscreenautorotate)
* [fullscreenOrientation](#fullscreenorientation)
* [hideShutterView](#hideshutterview)
* [id](#id)
* [ignoreSilentSwitch](#ignoresilentswitch)
* [muted](#muted)
* [paused](#paused)
* [playInBackground](#playinbackground)
* [playWhenInactive](#playwheninactive)
* [poster](#poster)
* [posterResizeMode](#posterresizemode)
* [progressUpdateInterval](#progressupdateinterval)
* [rate](#rate)
* [repeat](#repeat)
* [resizeMode](#resizemode)
* [source](#source)
* [volume](#volume)

### Event props
* [onAudioBecomingNoisy](#onaudiobecomingnoisy)
* [onEnd](#onend)
* [onExternalPlaybackChange](#onexternalplaybackchange)
* [onFullscreenPlayerWillPresent](#onfullscreenplayerwillpresent)
* [onFullscreenPlayerDidPresent](#onfullscreenplayerdidpresent)
* [onFullscreenPlayerWillDismiss](#onfullscreenplayerwilldismiss)
* [onFullscreenPlayerDidDismiss](#onfullscreenplayerdiddismiss)
* [onLoad](#onload)
* [onLoadStart](#onloadstart)
* [onProgress](#onprogress)
* [onSeek](#onseek)
* [onTimedMetadata](#ontimedmetadata)

### Methods
* [dismissFullscreenPlayer](#dismissfullscreenplayer)
* [presentFullscreenPlayer](#presentfullscreenplayer)
* [save](#save)
* [seek](#seek)

### Configurable props

#### allowsExternalPlayback
Indicates whether the player allows switching to external playback mode such as AirPlay or HDMI.
* **true (default)** - allow switching to external playback mode
* **false** -  Don't allow switching to external playback mode

Platforms: iOS

#### audioOnly
Indicates whether the player should only play the audio track and instead of displaying the video track, show the poster instead.
* **false (default)** - Display the video as normal
* **true** - Show the poster and play the audio

For this to work, the poster prop must be set.

Platforms: all

#### bufferConfig
Adjust the buffer settings. This prop takes an object with one or more of the properties listed below.

Property | Type | Description
--- | --- | ---
minBufferMs | number | The default minimum duration of media that the player will attempt to ensure is buffered at all times, in milliseconds.
maxBufferMs | number | The default maximum duration of media that the player will attempt to buffer, in milliseconds.
bufferForPlaybackMs | number | The default duration of media that must be buffered for playback to start or resume following a user action such as a seek, in milliseconds.
playbackAfterRebufferMs | number | The default duration of media that must be buffered for playback to resume after a rebuffer, in milliseconds. A rebuffer is defined to be caused by buffer depletion rather than a user action.

This prop should only be set when you are setting the source, changing it after the media is loaded will cause it to be reloaded.

Example with default values:
```
bufferConfig={{
  minBufferMs: 15000,
  maxBufferMs: 50000,
  bufferForPlaybackMs: 2500,
  bufferForPlaybackAfterRebufferMs: 5000
}}
```

Platforms: Android ExoPlayer

#### controls
Determines whether to show player controls.
* ** false (default)** - Don't show player controls
* **true** - Show player controls

Note on iOS, controls are always shown when in fullscreen mode.

Platforms: iOS, react-native-dom

#### filter
Add video filter
* **FilterType.NONE (default)** - No Filter
* **FilterType.INVERT** - CIColorInvert
* **FilterType.MONOCHROME** - CIColorMonochrome
* **FilterType.POSTERIZE** - CIColorPosterize
* **FilterType.FALSE** - CIFalseColor
* **FilterType.MAXIMUMCOMPONENT** - CIMaximumComponent
* **FilterType.MINIMUMCOMPONENT** - CIMinimumComponent
* **FilterType.CHROME** - CIPhotoEffectChrome
* **FilterType.FADE** - CIPhotoEffectFade
* **FilterType.INSTANT** - CIPhotoEffectInstant
* **FilterType.MONO** - CIPhotoEffectMono
* **FilterType.NOIR** - CIPhotoEffectNoir
* **FilterType.PROCESS** - CIPhotoEffectProcess
* **FilterType.TONAL** - CIPhotoEffectTonal
* **FilterType.TRANSFER** - CIPhotoEffectTransfer
* **FilterType.SEPIA** - CISepiaTone

For more details on these filters refer to the [iOS docs](https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/uid/TP30000136-SW55).

Notes: 
1. Using a filter can impact CPU usage. A workaround is to save the video with the filter and then load the saved video.
2. Video filter is currently not supported on HLS playlists.

Platforms: iOS

#### fullscreen
Controls whether the player enters fullscreen on play.
* **false (default)** - Don't display the video in fullscreen
* **true** - Display the video in fullscreen

Platforms: iOS

#### fullscreenAutorotate
If a preferred [fullscreenOrientation](#fullscreenorientation) is set, causes the video to rotate to that orientation but permits rotation of the screen to orientation held by user. Defaults to TRUE.

Platforms: iOS

#### fullscreenOrientation

* **all (default)** - 
* **landscape**
* **portrait**

Platforms: iOS

#### ignoreSilentSwitch
Controls the iOS silent switch behavior
* **"inherit" (default)** - Use the default AVPlayer behavior
* **"ignore"** - Play audio even if the silent switch is set
* **"obey"** - Don't play audio if the silent switch is set

Platforms: iOS

#### muted
Controls whether the audio is muted
* **false (default)** - Don't mute audio
* **true** - Mute audio


#### paused
Controls whether the media is paused
* **false (default)** - Don't pause the media
* **true** - Pause the media


#### playInBackground
Determine whether the media should continue playing while the app is in the background. This allows customers to continue listening to the audio.
* **false (default)** - Don't continue playing the media
* **true** - Continue playing the media

To use this feature on iOS, you must:
* [Enable Background Audio](https://developer.apple.com/library/archive/documentation/Audio/Conceptual/AudioSessionProgrammingGuide/AudioSessionBasics/AudioSessionBasics.html#//apple_ref/doc/uid/TP40007875-CH3-SW3) in your Xcode project
* Set the ignoreSilentSwitch prop to "ignore"

Platforms:iOS

#### playWhenInactive
Determine whether the media should continue playing when notifications or the Control Center are in front of the video.
* **false (default)** - Don't continue playing the media
* **true** - Continue playing the media

Platforms: iOS

#### poster
An image to display while the video is loading
<br>Value: string with a URL for the poster, e.g. "https://baconmockup.com/300/200/"


#### posterResizeMode
Determines how to resize the poster image when the frame doesn't match the raw video dimensions.
* **"contain" (default)** - Scale the image uniformly (maintain the image's aspect ratio) so that both dimensions (width and height) of the image will be equal to or less than the corresponding dimension of the view (minus padding).
* **"center"** - Center the image in the view along both dimensions. If the image is larger than the view, scale it down uniformly so that it is contained in the view.
* **"cover"** - Scale the image uniformly (maintain the image's aspect ratio) so that both dimensions (width and height) of the image will be equal to or larger than the corresponding dimension of the view (minus padding).
* **"none"** - Don't apply resize
* **"repeat"** - Repeat the image to cover the frame of the view. The image will keep its size and aspect ratio. (iOS only)
* **"stretch"** - Scale width and height independently, This may change the aspect ratio of the src.

Platforms: all

#### progressUpdateInterval
Delay in milliseconds between onProgress events in milliseconds.

Default: 250.0

Platforms: all

### rate
Speed at which the media should play. 
* **0.0** - Pauses the video
* **1.0** - Play at normal speed
* **Other values** - Slow down or speed up playback


#### repeat
Determine whether to repeat the video when the end is reached
* **false (default)** - Don't repeat the video
* **true** - Repeat the video

#### resizeMode
Determines how to resize the video when the frame doesn't match the raw video dimensions.
* **"none" (default)** - Don't apply resize
* **"scaleToFill"** - Scale the video uniformly (maintain the video's aspect ratio) so that both dimensions (width and height) of the video will be equal to or less than the corresponding dimension of the view (minus padding).
* **"scaleAspectFit"** - Scale the video uniformly (maintain the video's aspect ratio) so that both dimensions (width and height) of the image will be equal to or larger than the corresponding dimension of the view (minus padding).
* **"scaleAspectFill"** - Scale width and height independently, This may change the aspect ratio of the src.

Platforms: Android ExoPlayer, Android MediaPlayer, iOS, Windows UWP

#### source
Sets the media source. You can pass an asset loaded via require or an object with a uri.

The docs for this prop are incomplete and will be updated as each option is investigated and tested.

##### Asset loaded via require

Example: 
```
const sintel = require('./sintel.mp4');

source={sintel}
```

##### URI string

A number of URI schemes are supported by passing an object with a `uri` attribute.

###### Web address (http://, https://)

Example:
```
source={ uri: 'https://www.sample-videos.com/video/mp4/720/big_buck_bunny_720p_10mb.mp4' }
```

Platforms: all

###### File path (file://)

Example:
```
source={ uri: 'file:///sdcard/Movies/sintel.mp4' }
```

Note: Your app will need to request permission to read external storage if you're accessing a file outside your app.

Platforms: Android ExoPlayer, Android MediaPlayer, possibly others

###### iPod Library (ipod-library://)

Path to a sound file in your iTunes library. Typically shared from iTunes to your app.

Example:
```
source={ uri: 'ipod-library:///path/to/music.mp3' }
```

Note: Using this feature adding an entry for NSAppleMusicUsageDescription to your Info.plist file as described [here](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html)

Platforms: iOS

###### Other protocols

The following other types are supported on some platforms, but aren't fully documented yet:
`content://, ms-appx://, ms-appdata://, assets-library://`

#### volume
Adjust the volume.
* **1.0 (default)** - Play at full volume
* **0.0** - Mute the audio
* **Other values** - Reduce volume

Platforms: all

### Event props

#### onAudioBecomingNoisy
Callback function that is called when the audio is about to become 'noisy' due to a change in audio outputs. Typically this is called when audio output is being switched from an external source like headphones back to the internal speaker. It's a good idea to pause the media when this happens so the speaker doesn't start blasting sound.

Payload: none

Platforms: iOS

#### onEnd
Callback function that is called when the player reaches the end of the media.

Payload: none


#### onExternalPlaybackChange
Callback function that is called when external playback mode for current playing video has changed. Mostly useful when connecting/disconnecting to Apple TV – it's called on connection/disconnection.

Payload:

Property | Type | Description
--- | --- | ---
isExternalPlaybackActive | boolean | Boolean indicating whether external playback mode is active

Example:
```
{
  isExternalPlaybackActive: true
}
```

Platforms: iOS

#### onFullscreenPlayerWillPresent
Callback function that is called when the player is about to enter fullscreen mode.

Payload: none

Platforms: iOS

#### onFullscreenPlayerDidPresent
Callback function that is called when the player has entered fullscreen mode.

Payload: none

Platforms: iOS

#### onFullscreenPlayerWillDismiss
Callback function that is called when the player is about to exit fullscreen mode.

Payload: none

Platforms: iOS

#### onFullscreenPlayerDidDismiss
Callback function that is called when the player has exited fullscreen mode.

Payload: none

Platforms: iOS

#### onLoad
Callback function that is called when the media is loaded and ready to play.

Payload:

Property | Type | Description
--- | --- | ---
currentPosition | number | Time in seconds where the media will start
duration | number | Length of the media in seconds
naturalSize | object | Properties:<br> * width - Width in pixels that the video was encoded at<br> * height - Height in pixels that the video was encoded at<br> * orientation - "portrait" or "landscape"
audioTracks | array | An array of audio track info objects with the following properties:<br> * index - Index number<br> * title - Description of the track<br> * language - 2 letter [ISO 639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) or 3 letter [ISO639-2](https://en.wikipedia.org/wiki/List_of_ISO_639-2_codes) language code<br> * type - Mime type of track
textTracks | array | An array of text track info objects with the following properties:<br> * index - Index number<br> * title - Description of the track<br> * language - 2 letter [ISO 639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) or 3 letter [ISO 639-2](https://en.wikipedia.org/wiki/List_of_ISO_639-2_codes) language code<br> * type - Mime type of track

Example:
```
{ 
  canPlaySlowForward: true,
  canPlayReverse: false,
  canPlaySlowReverse: false,
  canPlayFastForward: false,
  canStepForward: false,
  canStepBackward: false,
  currentTime: 0,
  duration: 5910.208984375,
  naturalSize: {
     height: 1080
     orientation: 'landscape'
     width: '1920'
  },
  audioTracks: [
    { language: 'es', title: 'Spanish', type: 'audio/mpeg', index: 0 },
    { language: 'en', title: 'English', type: 'audio/mpeg', index: 1 }
  ],
  textTracks: [
    { title: '#1 French', language: 'fr', index: 0, type: 'text/vtt' },
    { title: '#2 English CC', language: 'en', index: 1, type: 'text/vtt' },
    { title: '#3 English Director Commentary', language: 'en', index: 2, type: 'text/vtt' }
  ]
}
```

Platforms: all

#### onLoadStart
Callback function that is called when the media starts loading.

Payload:

Property | Description
--- | ---
isNetwork | boolean | Boolean indicating if the media is being loaded from the network
type | string | Type of the media. Not available on Windows
uri | string | URI for the media source. Not available on Windows

Example:
```
{
  isNetwork: true,
  type: '',
  uri: 'https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8'
}
```

#### onProgress
Callback function that is called every progressUpdateInterval seconds with info about which position the media is currently playing.

Property | Type | Description
--- | --- | ---
currentTime | number | Current position in seconds
playableDuration | number | Position to where the media can be played to using just the buffer in seconds
seekableDuration | number | Position to where the media can be seeked to in seconds. Typically, the total length of the media

Example:
```
{
  currentTime: 5.2,
  playableDuration: 34.6,
  seekableDuration: 888
}
```

#### onSeek
Callback function that is called when a seek completes.

Payload:

Property | Type | Description
--- | --- | ---
currentTime | number | The current time after the seek
seekTime | number | The requested time

Example:
```
{
  currentTime: 100.5
  seekTime: 100
}
```

Both the currentTime & seekTime are reported because the video player may not seek to the exact requested position in order to improve seek performance.


Platforms: Android ExoPlayer, Android MediaPlayer, iOS, Windows UWP

#### onTimedMetadata
Callback function that is called when timed metadata becomes available

Payload:

Property | Type | Description
--- | --- | ---
metadata | array | Array of metadata objects

Example:
```
{
  metadata: [
    { value: 'Streaming Encoder', identifier: 'TRSN' },
    { value: 'Internet Stream', identifier: 'TRSO' },
    { value: 'Any Time You Like', identifier: 'TIT2' }
  ]
}
```

Support for timed metadata on Android MediaPlayer is limited at best and only compatible with some videos. It requires a target SDK of 23 or higher.

Platforms: Android ExoPlayer, Android MediaPlayer, iOS

### Methods
Methods operate on a ref to the Video element. You can create a ref using code like:
```
return (
  <Video source={...}
    ref => (this.player = ref) />
);
```

#### dismissFullscreenPlayer
`dismissFullscreenPlayer()`

Take the player out of fullscreen mode.

Example:
```
this.player.dismissFullscreenPlayer();
```

Platforms: iOS

#### presentFullscreenPlayer
`presentFullscreenPlayer()`

Put the player in fullscreen mode.

On iOS, this displays the video in a fullscreen view controller with controls.

On Android ExoPlayer & MediaPlayer, this puts the navigation controls in fullscreen mode. It is not a complete fullscreen implementation, so you will still need to apply a style that makes the width and height match your screen dimensions to get a fullscreen video.

Example:
```
this.player.presentFullscreenPlayer();
```

Platforms: iOS

#### save
`save(): Promise`

Save video to your Photos with current filter prop. Returns promise.

Example:
```
let response = await this.save();
let path = response.uri;
```

Notes:
 - Currently only supports highest quality export
 - Currently only supports MP4 export
 - Currently only supports exporting to user's cache directory with a generated UUID filename. 
 - User will need to remove the saved video through their Photos app
 - Works with cached videos as well. (Checkout video-caching example)
 - If the video is has not began buffering (e.g. there is no internet connection) then the save function will throw an error.
 - If the video is buffering then the save function promise will return after the video has finished buffering and processing.
 
Future: 
 - Will support multiple qualities through options
 - Will support more formats in the future through options
 - Will support custom directory and file name through options
 
Platforms: iOS

#### seek()
`seek(seconds)`

Seek to the specified position represented by seconds. seconds is a float value.

`seek()` can only be called after the `onLoad` event has fired. Once completed, the [onSeek](#onseek) event will be called.

Example:
```
this.player.seek(200); // Seek to 3 minutes, 20 seconds
```

Platforms: all

##### Exact seek

By default iOS seeks within 100 milliseconds of the target position. If you need more accuracy, you can use the seek with tolerance method:

`seek(seconds, tolerance)`

tolerance is the max distance in milliseconds from the seconds position that's allowed. Using a more exact tolerance can cause seeks to take longer. If you want to seek exactly, set tolerance to 0.

Example:
```
this.player.seek(120, 50); // Seek to 2 minutes with +/- 50 milliseconds accuracy
```

