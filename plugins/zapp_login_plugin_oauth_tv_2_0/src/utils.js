import { localStorage } from "@applicaster/zapp-react-native-bridge/ZappStorage/LocalStorage";

export function uuidv4() {
  return "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, function (c) {
    var r = (Math.random() * 16) | 0,
      v = c == "x" ? r : (r & 0x3) | 0x8;
    return v.toString(16);
  });
}

export const skipPrehook = async (skip, namespace, closeHook, event) => {
  localStorage.setItem(skip, true, namespace);
  closeHook({ success: true });
};
