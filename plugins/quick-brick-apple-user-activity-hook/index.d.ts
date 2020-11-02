declare module "@applicaster/quick-brick-apple-user-activity-hook";

declare type UserActivityPayload = {
  contentId: string;
};

declare interface AppleUserActivityBridgeI {
  defineUserActivity(UserActivityPayload): void;
  removeUserActivity(): void;
}
