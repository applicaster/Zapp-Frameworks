import * as R from "ramda";

export function getIMAData({ entry, pluginConfiguration }) {
  if (pluginConfiguration?.google_ima_enabled === "DISABLED") {
    return null;
  }

  const adsData = getZappAdsData({ entry, pluginConfiguration });
  if (R.is(String)(adsData)) {
    return [
      {
        sources: adsData,
      },
    ];
  } else if (R.is(Array)(adsData)) {
    return R.map(mapToTheoAds)(adsData);
  }
  return null;
}

function mapToTheoAds(item) {
  if (item.offset === "preroll") {
    return {
      sources: item.ad_url,
      timeOffset: "start",
    };
  } else if (item.offset === "postroll") {
    return {
      sources: item.ad_url,
      timeOffset: "end",
    };
  } else if (item.offset) {
    return {
      sources: item.ad_url,
      timeOffset: item.offset,
    };
  }

  return null;
}

function getZappAdsData({ entry, pluginConfiguration }) {
  const adsFromEntry = R.path(["extensions", "video_ads"])(entry);
  if (adsFromEntry) {
    return adsFromEntry;
  }

  const {
    tag_vmap_url,
    tag_preroll_url,
    tag_postroll_url,
    tag_midroll_url,
    midroll_offset,
  } = pluginConfiguration;

  if (tag_vmap_url) {
    return tag_vmap_url;
  }

  const video_ads = [];

  // if (tag_preroll_url) {
  //   video_ads.push({
  //     offset: "preroll",
  //     ad_url: tag_preroll_url,
  //   });
  // }

  // if (tag_postroll_url) {
  //   video_ads.push({
  //     offset: "postroll",
  //     ad_url: tag_postroll_url,
  //   });
  // }

  // if (tag_midroll_url && midroll_offset) {
  //   video_ads.push({
  //     offset: String(midroll_offset),
  //     ad_url: tag_midroll_url,
  //   });
  // }
  return video_ads;
}
