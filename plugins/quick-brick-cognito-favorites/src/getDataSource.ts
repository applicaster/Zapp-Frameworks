import { getAllFavorites } from "@applicaster/zapp-react-native-bridge/Favorites";

function getFeed(entry) {
  return {
    id: "favourites_1",
    title: "Favorites",
    summary: "",
    entry,
  };
}

export async function getDataSource(url: string, extraProps: {}) {
  try {
    const favourites = await getAllFavorites();

    const data = getFeed(favourites);

    return { status: 200, data };
  } catch (error) {
    return { status: 500, error, data: {} };
  }
}
