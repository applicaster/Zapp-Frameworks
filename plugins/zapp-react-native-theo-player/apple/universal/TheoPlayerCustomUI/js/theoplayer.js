function init({ player }) {
  if (player) {
    // setting up the rewind button by setting up a video-js component
    var Button = THEOplayer.videojs.getComponent('Button');
    var RewindButton = THEOplayer.videojs.extend(Button, {
      constructor: function() {
        Button.apply(this, arguments);
        /* initialize your button */
      },
      handleClick: () => {
        player.currentTime -= 10;
      },
      buildCSSClass: function () {
        return 'custom-icon-rewind'; // insert all class names here
      }
    });

    THEOplayer.videojs.registerComponent('RewindButton', RewindButton);
    player.ui.getChild('controlBar').addChild('RewindButton', {});

    // setting up the forward button by setting up a video-js component
    var Button = THEOplayer.videojs.getComponent('Button');
    var ForwardButton = THEOplayer.videojs.extend(Button, {
      constructor: function() {
        Button.apply(this, arguments);
        /* initialize your button */
      },
      handleClick: () => {
        player.currentTime += 10;
      },
      buildCSSClass: function () {
        return 'custom-icon-forward'; // insert all class names here
      }
    });

    THEOplayer.videojs.registerComponent('ForwardButton', ForwardButton);
    player.ui.getChild('controlBar').addChild('ForwardButton', {});
  }
}
