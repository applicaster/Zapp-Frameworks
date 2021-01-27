import { AWSCognito } from "./AWSCognito";
import { Other } from "./Other";

export function getConfig({ configuration }) {
  const provider_selector = configuration?.provider_selector;

  if (provider_selector) {
    switch (provider_selector) {
      case "aws_cognito":
        return AWSCognito.getConfig({ configuration });

      case "other":
        return Other.getConfig({ configuration });

      default:
        break;
    }
  }
  return null;
}
