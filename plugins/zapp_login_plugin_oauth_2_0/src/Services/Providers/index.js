import { awsCognito } from "./AWSCognito";
import { other } from "./Other";

export function getConfig({ configuration }) {
  const provider_selector = configuration?.provider_selector;
  console.log({ configuration, provider_selector, other });

  if (provider_selector) {
    switch (provider_selector) {
      case "aws_cognito":
        return awsCognito.getConfig({ configuration });

      case "other":
        return other.getConfig({ configuration });

      default:
        break;
    }
  }
  return null;
}
