import { getPluginData } from "../../../Utils";

export default function createStyleSheet(screenData) {
  const {
    account_component_instructions_fontcolor: instructionsFontColor,
    account_component_instructions_fontsize: instructionsFontSize,
    account_component_greetings_fontcolor: greetingsFontColor,
    account_component_greetings_fontsize: greetingsFontSize,
    login_action_button_fontcolor: loginButtonFontColor,
    login_action_button_fontsize: loginButtonFontSize,
    logout_action_button_fontcolor: logoutButtonFontColor,
    logout_action_button_fontsize: logoutButtonFontSize,
    authorization_provider_title_fontcolor: authProviderTitleFontColor,
    authorization_provider_title_fontsize: authProviderTitleFontSize,
    login_action_button_applicaster_fontsize: loginButtonApplicasterFontSize,
    login_action_button_applicaster_fontcolor: loginButtonApplicasterFontColor,
  } = getPluginData(screenData);

  const instructionsStyle = {
    color: instructionsFontColor,
    fontSize: instructionsFontSize,
  };

  const greetingsStyle = {
    color: greetingsFontColor,
    fontSize: greetingsFontSize,
  };

  const loginButtonApplicasterStyle = {
    color: loginButtonApplicasterFontColor,
    fontSize: loginButtonApplicasterFontSize,
  };

  const loginButtonStyle = {
    color: loginButtonFontColor,
    fontSize: loginButtonFontSize,
  };

  const logoutButtonStyle = {
    color: logoutButtonFontColor,
    fontSize: logoutButtonFontSize,
  };

  const authProviderTitleStyle = {
    color: authProviderTitleFontColor,
    fontSize: authProviderTitleFontSize,
  };

  return {
    loginButtonApplicasterStyle,
    instructionsStyle,
    greetingsStyle,
    loginButtonStyle,
    logoutButtonStyle,
    authProviderTitleStyle,
  };
}
