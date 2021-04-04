import * as R from "ramda";

export function fetchImageFromMetaByKey(entry, imageKey = "image_base") {
  const mediaGroup = entry?.media_group;
  if (mediaGroup) {
    const mediaItems = R.compose(
      R.flatten,
      R.map(R.prop("media_item")),
      R.filter(
        R.either(R.propEq("type", "image"), R.propEq("type", "thumbnail"))
      )
    )(mediaGroup);
    if (mediaItems) {
      return R.compose(
        R.prop("src"),
        R.defaultTo(R.head(mediaItems)),
        R.when(R.isNil, () =>
          R.find(R.propEq("key", "image_base"), mediaItems)
        ),
        R.find(R.propEq("key", imageKey))
      )(mediaItems);
    }
  }
  return "";
}
