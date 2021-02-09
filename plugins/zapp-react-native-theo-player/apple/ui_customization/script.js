function init({ player })
{
    if (player) {
        // setting up the forward button by setting up a video-js component
        var Button = THEOplayer.videojs.getComponent('Button');
        var CloseButton = THEOplayer.videojs.extend(Button, {
            constructor: function() {
                Button.apply(this, arguments);
                /* initialize your button */
            },
            handleClick: () => {
            var event = {"type" : "onCloseButtonHandle"}
            if(theoplayerAndroid === undefined) {
                window.webkit.messageHandlers.onJSMessageReceived.postMessage(event);
              } else {
                theoplayerAndroid.sendMessage("onJSMessageReceived", JSON.stringify(event));
              }
            },
            buildCSSClass: function() {
                return 'vjs-icon-close'; // insert all class names here
            }
        });

        THEOplayer.videojs.registerComponent('CloseButton', CloseButton);
        player.ui.addChild('CloseButton', {});
//        player.ui.getChild('controlBar').addChild('CloseButton', {});
    }
}
