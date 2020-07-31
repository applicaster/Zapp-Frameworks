import { postAnalyticEvent } from '@applicaster/zapp-react-native-utils/analyticsUtils/manager';

export default function trackEvent(event, props) {
  try {
    const data = getAnalyticsData(props);
    const timestamp = Date.now();

    return postAnalyticEvent(event, {
      ...data,
      timestamp
    });
  } catch (err) {
    throw err;
  }
}

function getAnalyticsData(props) {
  const {
    payload = {},
    screenData: {
      type: pluginProvider
    } = {}
  } = props;

  if (payload.type && payload.type.value) {
    return {
      contentType: payload.type.value,
      contentName: payload.title,
      pluginProvider
    };
  }

  return {
    contentName: 'App',
    pluginProvider
  };
}
