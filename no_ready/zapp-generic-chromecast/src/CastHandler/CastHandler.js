import * as React from "react";
import { useNavigation } from "@applicaster/zapp-react-native-utils/reactHooks/navigation";
import { imageSrcFromMediaItem } from "@applicaster/zapp-react-native-ui-components/Components/MasterCell/MappingFunctions";
import { BufferAnimation } from "@applicaster/zapp-react-native-ui-components/Components/PlayerController/BufferAnimation";

type Item = {
  id: string | number,
  [string]: any,
};

type Props = {
  item: Item,
  plugin: {},
  feedId: ?string,
  feedTitle: ?string,
};

export function CastHandler(props: Props) {
  const item = props?.item;
  const Cast = props?.plugin;
  const navigator = useNavigation();

  const poster = imageSrcFromMediaItem(item, ["chromecast_poster"]);
  const image = imageSrcFromMediaItem(item, ["image_base"]);
  const media = {
    title: item?.title,
    subtitle: item?.summary,
    studio: item?.author?.name,
    duration: item?.extensions?.duration,
    mediaUrl: item?.content?.src,
    imageUrl: image,
    posterUrl: poster,
  };

  // TODO: retreive feed data
  const analytics = {
    feedId: props?.feedId,
    feedTitle: props?.feedTitle,
    entryId: item?.id,
    itemName: item?.title,
    vodType: item?.content?.type,
    free: item?.extensions?.free,
  };

  React.useEffect(() => {
    Cast.castMedia({ ...media, analytics })
      .then(() => {
        Cast.launchExpandedControls();
        navigator.goBack();
        // TODO: See why we have to navigate back twice to remove arrow:
        // https://drive.google.com/file/d/130FmmyREKxJ5jZL3c6_3G34-r1IYrdv7/view?usp=sharing
        navigator.goBack();
      })
      .catch((error) => {
        // eslint-disable-next-line no-console
        console.warn({ error });
        navigator?.goHome();
      });
  }, []);

  return <BufferAnimation />;
}
