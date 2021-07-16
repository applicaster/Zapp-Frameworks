const buttonKey = "button";
export function styleForLogin1Button(styles: GeneralStyles): ButtonStyles {
  return getStylesForButton(styles, `${buttonKey}_1_`);
}

export function styleForLogin2Button(styles: GeneralStyles): ButtonStyles {
  return getStylesForButton(styles, `${buttonKey}_2_`);
}

export function styleForLogoutButton(styles: GeneralStyles): ButtonStyles {
  return getStylesForButton(styles, `${buttonKey}_logout_`);
}

function getStylesForButton(styles: Styles, key: string): ButtonStyles {
  console.log({ styles, key, too: styles[`${key}background_underlay_color`] });

  return {
    containerStyle: {
      background_underlay_color: styles[`${key}background_underlay_color`],
      background_color: styles[`${key}background_color`],
      radius: styles[`${key}radius`],
      border: styles[`${key}border`],
      border_color: styles[`${key}border_color`],
      border_underlay: styles[`${key}border_underlay`],
      border_underlay_color: styles[`${key}border_underlay_color`],
    },
    labelStyles: {
      title_underlay_color: styles[`${key}title_underlay_color`],
      title_color: styles[`${key}title_color`],
      title_text_fontsize: styles[`${key}title_text_fontsize`],
      title_text_font_ios: styles[`${key}title_text_font_ios`],
      title_text_font_android: styles[`${key}title_text_font_android`],
    },
  };
}
