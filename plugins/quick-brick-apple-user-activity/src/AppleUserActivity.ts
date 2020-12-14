import { useNavigation } from "@applicaster/zapp-react-native-utils/reactHooks/navigation";

import { defineUserActivity, removeUserActivity } from "./bridge";

export function useScreenHook({ useEffect }) {
  const { screenData } = useNavigation();

  useEffect(() => {
    const contentId = screenData?.extensions?.apple_user_activity_content_id;

    if (contentId) {
      defineUserActivity({ apple_user_activity_content_id: contentId });

      return () => {
        removeUserActivity();
      };
    }
  });
}
