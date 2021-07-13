import { postAnalyticEvent } from "@applicaster/zapp-react-native-utils/analyticsUtils/manager";

const eventCategory = "First-Time-User-Experience";
type AnalyticEvent = { action: string; label: string; value: string };
import {
  createLogger,
  BaseSubsystem,
  BaseCategories,
} from "../../Services/LoggerService";

const logger = createLogger({
  subsystem: BaseSubsystem,
  category: BaseCategories.ANALYTICS,
});

export async function sendEvent(data: AnalyticEvent) {
  const event = `${eventCategory}: ${data.action}`;
  console.log("sendEvent", { event, data });
  logger.log({
    message: `sendEvent: eventName - ${event}`,
    data: data,
  });
  return await postAnalyticEvent(event, data);
}
