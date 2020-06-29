declare module "react-native-google-cast" {
  import * as React from "react";

  export type CastState =
    | "NoDevicesAvailable"
    | "NotConnected"
    | "Connecting"
    | "Connected";

  export type Media = {
    title: string;
    subtitle: string;
    studio: string;
    duration: number;
    mediaUrl: string;
    imageUrl: string;
    posterUrl: string;
    analytics: {
      feedId: string;
      feedTitle: string;
      entryId: string;
      itemName: string;
      vodType: string;
      free: boolean;
    };
  };

  export type Props = {
    origin: string;
    tintColor: string;
  };

  const GoogleCast: {
    castMedia(params: Media): Promise<any>;
    getCastState(): Promise<CastState>;
    isCasting(): boolean;
    hasConnectedCastSession(): boolean;
    play(): void;
    pause(): void;
    stop(): void;
    seek(playPosition: number): void;
    launchExpandedControls(): void;
    showIntroductoryOverlay(): void;
    setVolume(volume: number): void;
  };

  export default GoogleCast;

  export function Component(props: Props): React.Component {}
}
