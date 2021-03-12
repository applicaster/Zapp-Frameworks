const R = require("ramda");
const Localizations = require("./localizations.config");

const baseManifest = {
  dependency_repository_url: [],
  dependency_name: "@applicaster/quick-brick-inplayer",
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "inPlayer Login & Payments",
  description: "inPlayer Login & Payments",
  type: "login",
  screen: true,
  react_native: true,
  identifier: "quick-brick-inplayer",
  ui_builder_support: true,
  whitelisted_account_ids: ["5c9ce7917b225c000f02dfbc"],
  deprecated_since_zapp_sdk: "",
  unsupported_since_zapp_sdk: "",
  preload: true,
  custom_configuration_fields: [
    {
      type: "text",
      key: "in_player_client_id",
      tooltip_text: "In Player Client ID",
      default: "",
    },
    {
      type: "number_input",
      key: "in_player_branding_id",
      tooltip_text: "In Player Branding ID",
    },
    {
      type: "text",
      key: "in_player_referrer",
      tooltip_text: "In Player Referrer URL",
      default: "",
    },
    {
      type: "text",
      key: "in_player_custom_asset_key",
      tooltip_text: "Custom asset key",
      default: "extensions.event_inplayer_id",
    },
    {
      type: "tag_select",
      key: "in_player_environment",
      tooltip_text: "InPlayer working environment",
      options: [
        {
          text: "Development",
          value: "development",
        },
        {
          text: "Production",
          value: "production",
        },
      ],
      initial_value: "production",
    },
    {
      type: "tag_select",
      key: "logout_completion_action",
      tooltip_text: "Defines what action plugin should do after user log out. ",
      options: [
        {
          text: "Go back to previous screen",
          value: "go_back",
        },
        {
          text: "Go back to home screen",
          value: "go_home",
        },
      ],
      initial_value: "go_back",
    },
    {
      type: "text",
      key: "consumable_type_mapper",
      tooltip_text: "Mapping key for consumable purchase",
      default: "consumable",
    },
    {
      type: "text",
      key: "non_consumable_type_mapper",
      tooltip_text: "Mapping key for non consumable purchase",
      default: "ppv",
    },
    {
      type: "text",
      key: "subscription_type_mapper",
      tooltip_text: "Mapping key for subscription purchase",
      default: "subscription",
    },
  ],
  hooks: {
    fields: [
      {
        group: true,
        label: "Before Load",
        folded: true,
        fields: [
          {
            key: "preload_plugins",
            type: "preload_plugins_selector",
            label: "Select Plugins",
          },
        ],
      },
    ],
  },
  ui_frameworks: ["quickbrick"],
};

const stylesMobile = {
  fields: [
    {
      key: "background_color",
      type: "color_picker",
      label: "Background font color",
      initial_value: "#161b29ff",
    },
    {
      key: "title_font_ios",
      type: "ios_font_selector",
      label: "iOS title font",
      initial_value: "Roboto-Bold",
    },
    {
      key: "title_font_android",
      type: "android_font_selector",
      label: "Android title font",
      initial_value: "Roboto-Bold",
    },
    {
      key: "title_font_size",
      type: "number_input",
      label: "Title font size",
      initial_value: 15,
    },
    {
      key: "title_font_color",
      type: "color_picker",
      label: "Title font color",
      initial_value: "#ffffffff",
    },
    {
      key: "back_button_font_ios",
      type: "ios_font_selector",
      label: "iOS back button font",
      initial_value: "Roboto-Bold",
    },
    {
      key: "back_button_font_android",
      type: "android_font_selector",
      label: "Android back button font",
      initial_value: "Roboto-Bold",
    },
    {
      key: "back_button_font_size",
      type: "number_input",
      label: "Back button font size",
      initial_value: 15,
    },
    {
      key: "back_button_font_color",
      type: "color_picker",
      label: "Back button font color",
      initial_value: "#ffffffff",
    },
    {
      key: "fields_font_ios",
      type: "ios_font_selector",
      label: "iOS input fields title font",
      initial_value: "Roboto-Bold",
    },
    {
      key: "fields_font_android",
      type: "android_font_selector",
      label: "Android input fields title font",
      initial_value: "Roboto-Bold",
    },
    {
      key: "fields_font_size",
      type: "number_input",
      label: "Input fields title font size",
      initial_value: 13,
    },
    {
      key: "fields_font_color",
      type: "color_picker",
      label: "Input fields font color",
      initial_value: "#ffffffff",
    },
    {
      key: "fields_placeholder_font_color",
      type: "color_picker",
      label: "Input fields placeholder font color",
      initial_value: "#ffffffff",
    },
    {
      key: "fields_separator_color",
      type: "color_picker",
      label: "Input fields separator color",
      initial_value: "#a9a9a9ff",
    },
    {
      key: "forgot_password_font_ios",
      type: "ios_font_selector",
      label: "iOS forgot password font",
      initial_value: "Roboto-Regular",
    },
    {
      key: "forgot_password_font_android",
      type: "android_font_selector",
      label: "Android forgot password font",
      initial_value: "Roboto-Regular",
    },
    {
      key: "forgot_password_font_size",
      type: "number_input",
      label: "Forgot password font size",
      initial_value: 11,
    },
    {
      key: "forgot_password_font_color",
      type: "color_picker",
      label: "Forgot password font color",
      initial_value: "#a9a9a9ff",
    },
    {
      key: "action_button_background_color",
      type: "color_picker",
      label: "iOS action button background color",
      initial_value: "#f1af13ff",
    },
    {
      key: "action_button_font_ios",
      type: "ios_font_selector",
      label: "iOS action button font",
      initial_value: "Roboto-Bold",
    },
    {
      key: "action_button_font_android",
      type: "android_font_selector",
      label: "Android action button font",
      initial_value: "Roboto-Bold",
    },
    {
      key: "action_button_font_size",
      type: "number_input",
      label: "Action button font size",
      initial_value: 15,
    },
    {
      key: "action_button_font_color",
      type: "color_picker",
      label: "Action button font Color",
      initial_value: "#ffffffff",
    },
    {
      key: "create_account_link_font_ios",
      type: "ios_font_selector",
      label: "iOS Create account link font",
      initial_value: "Roboto-Regular",
    },
    {
      key: "create_account_link_font_android",
      type: "android_font_selector",
      label: "Android Create account link font",
      initial_value: "Roboto-Regular",
    },
    {
      key: "create_account_link_font_size",
      type: "number_input",
      label: "Create account link font size",
      initial_value: 11,
    },
    {
      key: "create_account_link_font_color",
      type: "color_picker",
      label: "Create account link font color",
      initial_value: "#a9a9a9ff",
    },
    {
      key: "logout_background_color",
      type: "color_picker",
      label: "Logout background font color",
      initial_value: "#161b29ff",
    },
    {
      key: "logout_title_font_ios",
      type: "ios_font_selector",
      label: "Logout iOS title font",
      initial_value: "Roboto-Bold",
    },
    {
      key: "logout_title_font_android",
      type: "android_font_selector",
      label: "Logout Android title font",
      initial_value: "Roboto-Bold",
    },
    {
      key: "logout_title_font_size",
      type: "number_input",
      label: "Logout title font size",
      initial_value: 15,
    },
    {
      key: "logout_title_font_color",
      type: "color_picker",
      label: "Logout title font color",
      initial_value: "#ffffffff",
    },
  ],
};

const stylesTv = {
  fields: [
    {
      key: "client_logo",
      type: "uploader",
      label: "Client Logo",
      label_tooltip: "Client logo image. Dimension 200 x44.",
      placeholder: "W 200px x H 44px",
    },
    {
      group: true,
      label: "Logout Screen",
      tooltip: "This fields affect logout screen.",
      folded: true,
      fields: [
        {
          key: "logout_background_color",
          type: "color_picker",
          label: "Logout background font color",
          initial_value: "#161b29ff",
        },
        {
          key: "logout_title_font_tvos",
          type: "tvos_font_selector",
          label: "Logout tvOS title font",
          initial_value: "Helvetica-Bold",
        },
        {
          key: "logout_title_font_android_tv",
          type: "android_font_selector",
          label: "Logout Android title font",
          initial_value: "Roboto-Bold",
        },
        {
          key: "logout_title_font_size",
          type: "number_input",
          label: "Logout title font size",
          initial_value: 30,
        },
        {
          key: "logout_title_font_color",
          type: "color_picker",
          label: "Logout title font color",
          initial_value: "#ffffffff",
        },
      ],
    },
    {
      group: true,
      label: "Account Design and Text",
      tooltip: "These fields affect the design of the screen plugin.",
      folded: true,
      fields: [
        {
          key: "login_title_font_tvos",
          type: "tvos_font_selector",
          label_tooltip: "Font for Login Title Text for TvOS.",
          initial_value: "Helvetica-Bold",
        },
        {
          key: "login_title_font_android",
          type: "android_font_selector",
          label_tooltip: "Font for Login Title Text for Android TV.",
          initial_value: "Roboto-Bold",
        },
        {
          key: "login_title_fontsize",
          type: "number_input",
          label_tooltip: "Font Size for Login Title Text.",
          initial_value: "60",
        },
        {
          key: "login_title_fontcolor",
          type: "color_picker_rgba",
          label_tooltip: "Font Color for Login Title Text.",
          initial_value: "#545A5C",
        },
        {
          key: "main_description_font_tvos",
          type: "tvos_font_selector",
          label_tooltip: "Font for Main Description Text for TvOS.",
          initial_value: "Helvetica-Bold",
        },
        {
          key: "main_description_font_android",
          type: "android_font_selector",
          label_tooltip: "Font for Main Description Text for Android TV.",
          initial_value: "Roboto-Bold",
        },
        {
          key: "main_description_fontsize",
          type: "number_input",
          label_tooltip: "Font Size for Main Description Text.",
          initial_value: "38",
        },
        {
          key: "main_description_fontcolor",
          type: "color_picker_rgba",
          label_tooltip: "Font Color for Main Description Text.",
          initial_value: "#545A5C",
        },
        {
          key: "optional_instructions_1_font_tvos",
          type: "tvos_font_selector",
          label_tooltip: "Font for Optional Instructions 1 Text for TvOS.",
          initial_value: "Helvetica-Bold",
        },
        {
          key: "optional_instructions_1_font_android",
          type: "android_font_selector",
          label_tooltip:
            "Font for Optional Instructions 1 Text for Android TV.",
          initial_value: "Roboto-Bold",
        },
        {
          key: "optional_instructions_1_fontsize",
          type: "number_input",
          label_tooltip: "Font Size for Optional Instructions 1 Text.",
          initial_value: "26",
        },
        {
          key: "optional_instructions_1_fontcolor",
          type: "color_picker_rgba",
          label_tooltip: "Font Color for Optional Instructions 1 Text.",
          initial_value: "#545A5C",
        },
        {
          key: "optional_instructions_2_font_tvos",
          type: "tvos_font_selector",
          label_tooltip: "Font for Optional Instructions 2 Text for TvOS.",
          initial_value: "Helvetica-Bold",
        },
        {
          key: "optional_instructions_2_font_android",
          type: "android_font_selector",
          label_tooltip:
            "Font for Optional Instructions 2 Text for Android TV.",
          initial_value: "Roboto-Bold",
        },
        {
          key: "optional_instructions_2_fontsize",
          type: "number_input",
          label_tooltip: "Font Size for Optional Instructions 2 Text.",
          initial_value: "26",
        },
        {
          key: "optional_instructions_2_fontcolor",
          type: "color_picker_rgba",
          label_tooltip: "Font Color for Optional Instructions 2 Text.",
          initial_value: "#545A5C",
        },
        {
          key: "use_dark_keyboard",
          type: "switch",
          label: "Use Dark Keyboard",
          label_tooltip: "Enables the dark keyboard appearance.",
          initial_value: "false",
        },
        {
          key: "email_input_background",
          type: "color_picker_rgba",
          label: "Email Input Background Color",
          label_tooltip: "Background Color for the Email Input.",
          initial_value: "rgba(39, 218, 134, 1)",
        },
        {
          key: "email_input_background_focused",
          type: "color_picker_rgba",
          label: "Email Input Background Color (focused)",
          label_tooltip: "Background Color for the Focused Email Input.",
          initial_value: "rgba(39, 218, 134, 1)",
        },
        {
          key: "email_input_background_filled",
          type: "color_picker_rgba",
          label: "Email Input Background Color (filled)",
          label_tooltip: "Background Color for the Filled Email Input.",
          initial_value: "rgba(39, 218, 134, 1)",
        },
        {
          key: "email_input_border_color",
          type: "color_picker_rgba",
          label: "Email Input Border Color",
          label_tooltip: "Border Color for the Email Input.",
          initial_value: "rgba(39, 218, 134, 1)",
        },
        {
          key: "email_input_border_color_focused",
          type: "color_picker_rgba",
          label: "Email Input Border Color (focused)",
          label_tooltip: "Border Color for the Focused Email Input.",
          initial_value: "rgba(39, 218, 134, 1)",
        },
        {
          key: "email_input_border_color_filled",
          type: "color_picker_rgba",
          label: "Email Input Border Color (filled)",
          label_tooltip: "Border Color for the Filled Email Input.",
          initial_value: "rgba(39, 218, 134, 1)",
        },
        {
          key: "email_input_placeholder_color",
          type: "color_picker_rgba",
          label: "Email Input Placeholder Color (filled)",
          label_tooltip: "Color for the Email Input Placeholder.",
          initial_value: "#9B9B9B",
        },
        {
          key: "email_input_font_tvos",
          type: "tvos_font_selector",
          label_tooltip: "Font for Email Input Text for TvOS.",
          initial_value: "Helvetica-Bold",
        },
        {
          key: "email_input_font_android",
          type: "android_font_selector",
          label_tooltip: "Font for Email Input Text for Android TV.",
          initial_value: "Roboto-Bold",
        },
        {
          key: "email_input_fontsize",
          type: "number_input",
          label_tooltip: "Font Size for Email Input Field.",
          initial_value: "30",
        },
        {
          key: "email_input_fontcolor",
          type: "color_picker_rgba",
          label_tooltip: "Font Color for Email Input Field.",
          initial_value: "#9B9B9B",
        },
        {
          key: "password_input_background",
          type: "color_picker_rgba",
          label: "Password Input Background Color",
          label_tooltip: "Background Color for the Password Input.",
          initial_value: "rgba(39, 218, 134, 1)",
        },
        {
          key: "password_input_background_focused",
          type: "color_picker_rgba",
          label: "Password Input Background Color (focused)",
          label_tooltip: "Background Color for the Focused Password Input.",
          initial_value: "rgba(39, 218, 134, 1)",
        },
        {
          key: "password_input_background_filled",
          type: "color_picker_rgba",
          label: "Password Input Background Color (filled)",
          label_tooltip: "Background Color for the Filled Password Input.",
          initial_value: "rgba(39, 218, 134, 1)",
        },
        {
          key: "password_input_border_color",
          type: "color_picker_rgba",
          label: "Password Input Border Color",
          label_tooltip: "Border Color for the Password Input.",
          initial_value: "rgba(39, 218, 134, 1)",
        },
        {
          key: "password_input_border_color_focused",
          type: "color_picker_rgba",
          label: "Password Input Border Color (focused)",
          label_tooltip: "Border Color for the Focused Password Input.",
          initial_value: "rgba(39, 218, 134, 1)",
        },
        {
          key: "password_input_border_color_filled",
          type: "color_picker_rgba",
          label: "Password Input Border Color (filled)",
          label_tooltip: "Border Color for the Filled Password Input.",
          initial_value: "rgba(39, 218, 134, 1)",
        },
        {
          key: "password_input_placeholder_color",
          type: "color_picker_rgba",
          label: "Password Input Placeholder Color",
          label_tooltip: "Color for the Password Input Placeholder.",
          initial_value: "#9B9B9B",
        },
        {
          key: "password_input_font_tvos",
          type: "tvos_font_selector",
          label_tooltip: "Font for Password Input Text for TvOS.",
          initial_value: "Helvetica-Bold",
        },
        {
          key: "password_input_font_android",
          type: "android_font_selector",
          label_tooltip: "Font for Password Input Text for Android TV.",
          initial_value: "Roboto-Bold",
        },
        {
          key: "password_input_fontsize",
          type: "number_input",
          label_tooltip: "Font Size for Password Input Field.",
          initial_value: "30",
        },
        {
          key: "password_input_fontcolor",
          type: "color_picker_rgba",
          label_tooltip: "Font Color for Password Input Field.",
          initial_value: "#9B9B9B",
        },
        {
          key: "login_action_button_background",
          type: "color_picker_rgba",
          label: "Login Action Button Background Color",
          label_tooltip: "Background Color for the Login Action Button.",
          initial_value: "rgba(39, 218, 134, 1)",
        },
        {
          key: "login_action_button_background_focused",
          type: "color_picker_rgba",
          label: "Login Action Button Focused Background Color",
          label_tooltip: "Background Color for the Login Action Button",
          initial_value: "rgba(93, 2, 13, 1)",
        },
        {
          key: "login_action_button_font_tvos",
          type: "tvos_font_selector",
          label_tooltip: "Font for Login Action Button Text for TvOS.",
          initial_value: "Helvetica-Bold",
        },
        {
          key: "login_action_button_font_android",
          type: "android_font_selector",
          label_tooltip: "Font for Login Action Button Text for Android TV.",
          initial_value: "Roboto-Bold",
        },
        {
          key: "login_action_button_fontsize",
          type: "number_input",
          label_tooltip: "Font Size for Login Action Button Text.",
          initial_value: "40",
        },
        {
          key: "login_action_button_border_radius",
          type: "number_input",
          label: "Login Action Button Corner Radius",
          label_tooltip: "Corner radius for a login button.",
          initial_value: "5",
        },
        {
          key: "login_action_button_fontcolor",
          type: "color_picker_rgba",
          label_tooltip: "Font Color for Login Action Button Text.",
          initial_value: "#545A5C",
        },
        {
          key: "login_action_button_fontcolor_focused",
          type: "color_picker_rgba",
          label_tooltip: "Font Color for Focused Login Action Button Text.",
          initial_value: "#545A5C",
        },
        {
          key: "enable_skip_functionality",
          type: "switch",
          label: "Enable Skip Functionality",
          label_tooltip:
            "Enables the ability to skip the login by using the back button or activating the skip button in the UI.",
          initial_value: "true",
        },
        {
          key: "skip_action_button_background",
          type: "color_picker_rgba",
          label: "Skip Action Button Background Color",
          label_tooltip: "Background Color for the Skip Action Button.",
          initial_value: "rgba(39, 218, 134, 1)",
          conditional_fields: [
            {
              condition_value: [true],
              key: "general/enable_skip_functionality",
            },
          ],
        },
        {
          key: "skip_action_button_font_tvos",
          type: "tvos_font_selector",
          label_tooltip: "Font for Skip Action Button Text for TvOS.",
          initial_value: "Helvetica-Bold",
          conditional_fields: [
            {
              condition_value: [true],
              key: "general/enable_skip_functionality",
            },
          ],
        },
        {
          key: "skip_action_button_font_android",
          type: "android_font_selector",
          label_tooltip: "Font for Skip Action Button Text for Android TV.",
          initial_value: "Roboto-Bold",
          conditional_fields: [
            {
              condition_value: [true],
              key: "general/enable_skip_functionality",
            },
          ],
        },
        {
          key: "skip_action_button_fontsize",
          type: "number_input",
          label_tooltip: "Font Size for Skip Action Button Text.",
          initial_value: "40",
          conditional_fields: [
            {
              condition_value: [true],
              key: "general/enable_skip_functionality",
            },
          ],
        },
        {
          key: "skip_action_button_fontcolor",
          type: "color_picker_rgba",
          label_tooltip: "Font Color for Skip Action Button Text.",
          initial_value: "#545A5C",
          conditional_fields: [
            {
              condition_value: [true],
              key: "general/enable_skip_functionality",
            },
          ],
        },
      ],
    },
    {
      group: true,
      label: "Confirmation Screen Design and Text",
      tooltip: "These fields affect the design of plugin confirmation screen.",
      folded: true,
      fields: [
        {
          key: "confirmation_message_font_tvos",
          type: "tvos_font_selector",
          label_tooltip: "Font for Confirmation Text for TvOS.",
          initial_value: "Helvetica-Bold",
        },
        {
          key: "confirmation_message_font_android",
          type: "android_font_selector",
          label_tooltip: "Font for Confirmation Text for Android TV.",
          initial_value: "Roboto-Bold",
        },
        {
          key: "confirmation_message_fontsize",
          type: "number_input",
          label_tooltip: "Font Size for confirmation text.",
          initial_value: "41",
        },
        {
          key: "confirmation_message_fontcolor",
          type: "color_picker_rgba",
          label_tooltip: "Font Color for confirmation text.",
          initial_value: "#FFFFFF",
        },
        {
          key: "confirm_action_button_background",
          type: "color_picker_rgba",
          label: "Confirm Action Button Background Color",
          label_tooltip: "Background Color for the Confirm Action Button.",
          initial_value: "rgba(39, 218, 134, 1)",
        },
        {
          key: "confirm_action_button_font_tvos",
          type: "tvos_font_selector",
          label_tooltip: "Font for Confirm Button for TvOS.",
          initial_value: "Helvetica-Bold",
        },
        {
          key: "confirm_action_button_font_android",
          type: "android_font_selector",
          label_tooltip: "Font for Confirm Button for Android TV.",
          initial_value: "Roboto-Bold",
        },
        {
          key: "confirm_action_button_fontsize",
          type: "number_input",
          label_tooltip: "Font Size for Confirm Action Button Text.",
          initial_value: "40",
        },
        {
          key: "confirm_action_button_fontcolor",
          type: "color_picker_rgba",
          label_tooltip: "Font Color for Confirm Action Button Text.",
          initial_value: "#545A5C",
        },
        {
          key: "cancel_action_button_background",
          type: "color_picker_rgba",
          label: "Cancel Action Button Background Color",
          label_tooltip: "Background Color for the Cancel Action Button.",
          initial_value: "rgba(39, 218, 134, 1)",
        },
        {
          key: "cancel_action_button_font_tvos",
          type: "tvos_font_selector",
          label_tooltip: "Font for Cancel Button for TvOS.",
          initial_value: "Helvetica-Bold",
        },
        {
          key: "cancel_action_button_font_android",
          type: "android_font_selector",
          label_tooltip: "Font for Cancel Button for Android TV.",
          initial_value: "Roboto-Bold",
        },
        {
          key: "cancel_action_button_fontsize",
          type: "number_input",
          label_tooltip: "Font Size for Cancel Action Button Text.",
          initial_value: "40",
        },
        {
          key: "cancel_action_button_fontcolor",
          type: "color_picker_rgba",
          label_tooltip: "Font Color for Cancel Action Button Text.",
          initial_value: "#545A5C",
        },
      ],
    },
    {
      group: true,
      label: "Alert Design and Text",
      tooltip: "These fields affect the design of plugin alert component.",
      folded: true,
      fields: [
        {
          key: "error_description_font_tvos",
          type: "tvos_font_selector",
          label_tooltip: "Font for Description Text for TvOS.",
          initial_value: "Helvetica",
        },
        {
          key: "error_description_font_android",
          type: "android_font_selector",
          label_tooltip: "Font for Description Text for Android TV.",
          initial_value: "Roboto-Regular",
        },
        {
          key: "error_description_fontsize",
          type: "number_input",
          label_tooltip: "Font Size for Description Text.",
          initial_value: "36",
        },
        {
          key: "error_description_fontcolor",
          type: "color_picker_rgba",
          label_tooltip: "Font Color for Description Text.",
          initial_value: "rgba(84, 90, 92, 1)",
        },
        {
          key: "close_action_button_background",
          type: "color_picker_rgba",
          label: "Alert “OK” Action Button Background Color",
          label_tooltip:
            "Background Color for the Alert “OK” Action Button. Will be used if no assets found.",
          initial_value: "rgba(39, 218, 134, 1)",
        },
        {
          key: "close_action_button_font_tvos",
          type: "tvos_font_selector",
          label_tooltip: "Font for “OK” Action button Text for TvOS.",
          initial_value: "Helvetica",
        },
        {
          key: "close_action_button_font_android",
          type: "android_font_selector",
          label_tooltip: "Font for “OK” Action button Text for Android TV.",
          initial_value: "Roboto-Regular",
        },
        {
          key: "close_action_button_fontsize",
          type: "number_input",
          label_tooltip: "Font Size for Alert “OK” Action Button Text.",
          initial_value: "41",
        },
        {
          key: "close_action_button_fontcolor",
          type: "color_picker_rgba",
          label_tooltip: "Font Color for Alert “OK” Action Button Text.",
          initial_value: "rgba(84, 90, 92, 1)",
        },
      ],
    },
    {
      group: true,
      label: "Signup screen designs",
      tooltip: "These fields affect the design of the signup screen",
      folded: true,
      fields: [
        {
          key: "signup_title_font_tvos",
          type: "tvos_font_selector",
          label_tooltip: "Font for Signup Title Text for TvOS.",
          initial_value: "Helvetica-Bold",
        },
        {
          key: "signup_title_font_android",
          type: "android_font_selector",
          label_tooltip: "Font for Signup Title Text for Android TV.",
          initial_value: "Roboto-Bold",
        },
        {
          key: "signup_title_fontsize",
          type: "number_input",
          label_tooltip: "Font Size for Signup Title Text.",
          initial_value: "60",
        },
        {
          key: "signup_title_fontcolor",
          type: "color_picker_rgba",
          label_tooltip: "Font Color for Signup Title Text.",
          initial_value: "rgba(33, 35, 36, 1)",
        },
        {
          key: "signup_action_button_background",
          type: "color_picker_rgba",
          label: "Sign Up Action Button Background Color",
          label_tooltip: "Background Color for the Sign Up Action Button.",
          initial_value: "rgba(39, 218, 134, 1)",
        },
        {
          key: "signup_action_button_background_focused",
          type: "color_picker_rgba",
          label: "Sign Up Action Button Focused Background Color",
          label_tooltip: "Background Color for the Sign Up Action Button",
          initial_value: "rgba(93, 2, 13, 1)",
        },
        {
          key: "signup_action_button_font_tvos",
          type: "tvos_font_selector",
          label_tooltip: "Font for Sign Up Action Button Text for TvOS.",
          initial_value: "Helvetica-Bold",
        },
        {
          key: "signup_action_button_font_android",
          type: "android_font_selector",
          label_tooltip: "Font for Sign Up Action Button Text for Android TV.",
          initial_value: "Roboto-Bold",
        },
        {
          key: "signup_action_button_fontsize",
          type: "number_input",
          label_tooltip: "Font Size for Sign Up Action Button Text.",
          initial_value: "40",
        },
        {
          key: "signup_action_button_border_radius",
          type: "number_input",
          label: "Sign Up Action Button Corner Radius",
          label_tooltip: "Corner radius for a Sign Up button.",
          initial_value: "5",
        },
        {
          key: "signup_action_button_fontcolor",
          type: "color_picker_rgba",
          label_tooltip: "Font Color for Sign Up Action Button Text.",
          initial_value: "#545A5C",
        },
        {
          key: "signup_action_button_fontcolor_focused",
          type: "color_picker_rgba",
          label_tooltip: "Font Color for Focused Sign Up Action Button Text.",
          initial_value: "#545A5C",
        },
        {
          key: "signup_password_input_background",
          type: "color_picker_rgba",
          label: "Password Input Background Color",
          label_tooltip: "Background Color for the Password Input.",
          initial_value: "rgba(39, 218, 134, 1)",
        },
        {
          key: "signup_password_input_background_focused",
          type: "color_picker_rgba",
          label: "Password Input Background Color (focused)",
          label_tooltip: "Background Color for the Focused Password Input.",
          initial_value: "rgba(39, 218, 134, 1)",
        },
        {
          key: "signup_password_input_background_filled",
          type: "color_picker_rgba",
          label: "Password Input Background Color (filled)",
          label_tooltip: "Background Color for the Filled Password Input.",
          initial_value: "rgba(39, 218, 134, 1)",
        },
        {
          key: "signup_password_input_border_color",
          type: "color_picker_rgba",
          label: "Password Input Border Color",
          label_tooltip: "Border Color for the Password Input.",
          initial_value: "rgba(39, 218, 134, 1)",
        },
        {
          key: "signup_password_input_border_color_focused",
          type: "color_picker_rgba",
          label: "Password Input Border Color (focused)",
          label_tooltip: "Border Color for the Focused Password Input.",
          initial_value: "rgba(39, 218, 134, 1)",
        },
        {
          key: "signup_password_input_border_color_filled",
          type: "color_picker_rgba",
          label: "Password Input Border Color (filled)",
          label_tooltip: "Border Color for the Filled Password Input.",
          initial_value: "rgba(39, 218, 134, 1)",
        },
        {
          key: "signup_password_input_placeholder_color",
          type: "color_picker_rgba",
          label: "Password Input Placeholder Color",
          label_tooltip: "Color for the Password Input Placeholder.",
          initial_value: "#9B9B9B",
        },
        {
          key: "signup_password_input_font_tvos",
          type: "tvos_font_selector",
          label_tooltip: "Font for Password Input Text for TvOS.",
          initial_value: "Helvetica-Bold",
        },
        {
          key: "signup_password_input_font_android",
          type: "android_font_selector",
          label_tooltip: "Font for Password Input Text for Android TV.",
          initial_value: "Roboto-Bold",
        },
        {
          key: "signup_password_input_fontsize",
          type: "number_input",
          label_tooltip: "Font Size for Password Input Field.",
          initial_value: "30",
        },
        {
          key: "signup_password_input_fontcolor",
          type: "color_picker_rgba",
          label_tooltip: "Font Color for Password Input Field.",
          initial_value: "#9B9B9B",
        },
        {
          key: "signup_full_name_input_background",
          type: "color_picker_rgba",
          label: "Full Name Input Background Color",
          label_tooltip: "Background Color for the Full Name Input.",
          initial_value: "rgba(39, 218, 134, 1)",
        },
        {
          key: "signup_full_name_input_background_focused",
          type: "color_picker_rgba",
          label: "Full Name Input Background Color (focused)",
          label_tooltip: "Background Color for the Focused Full Name Input.",
          initial_value: "rgba(39, 218, 134, 1)",
        },
        {
          key: "signup_full_name_input_background_filled",
          type: "color_picker_rgba",
          label: "Full Name Input Background Color (filled)",
          label_tooltip: "Background Color for the Filled Full Name Input.",
          initial_value: "rgba(39, 218, 134, 1)",
        },
        {
          key: "signup_full_name_input_border_color",
          type: "color_picker_rgba",
          label: "Full Name Input Border Color",
          label_tooltip: "Border Color for the Full Name Input.",
          initial_value: "rgba(39, 218, 134, 1)",
        },
        {
          key: "signup_full_name_input_border_color_focused",
          type: "color_picker_rgba",
          label: "Full Name Input Border Color (focused)",
          label_tooltip: "Border Color for the Focused Full Name Input.",
          initial_value: "rgba(39, 218, 134, 1)",
        },
        {
          key: "signup_full_name_input_border_color_filled",
          type: "color_picker_rgba",
          label: "Full Name Input Border Color (filled)",
          label_tooltip: "Border Color for the Filled Full Name Input.",
          initial_value: "rgba(39, 218, 134, 1)",
        },
        {
          key: "signup_full_name_input_placeholder_color",
          type: "color_picker_rgba",
          label: "Full Name Input Placeholder Color",
          label_tooltip: "Color for the Full Name Input Placeholder.",
          initial_value: "#9B9B9B",
        },
        {
          key: "signup_full_name_input_font_tvos",
          type: "tvos_font_selector",
          label_tooltip: "Font for Full Name Input Text for TvOS.",
          initial_value: "Helvetica-Bold",
        },
        {
          key: "signup_full_name_input_font_android",
          type: "android_font_selector",
          label_tooltip: "Font for Full Name Input Text for Android TV.",
          initial_value: "Roboto-Bold",
        },
        {
          key: "signup_full_name_input_fontsize",
          type: "number_input",
          label_tooltip: "Font Size for Full Name Input Field.",
          initial_value: "30",
        },
        {
          key: "signup_full_name_input_fontcolor",
          type: "color_picker_rgba",
          label_tooltip: "Font Color for Full Name Input Field.",
          initial_value: "#9B9B9B",
        },
        {
          key: "signup_email_input_background",
          type: "color_picker_rgba",
          label: "Email Input Background Color",
          label_tooltip: "Background Color for the Email Input.",
          initial_value: "rgba(39, 218, 134, 1)",
        },
        {
          key: "signup_email_input_background_focused",
          type: "color_picker_rgba",
          label: "Email Input Background Color (focused)",
          label_tooltip: "Background Color for the Focused Email Input.",
          initial_value: "rgba(39, 218, 134, 1)",
        },
        {
          key: "signup_email_input_background_filled",
          type: "color_picker_rgba",
          label: "Email Input Background Color (filled)",
          label_tooltip: "Background Color for the Filled Email Input.",
          initial_value: "rgba(39, 218, 134, 1)",
        },
        {
          key: "signup_email_input_border_color",
          type: "color_picker_rgba",
          label: "Email Input Border Color",
          label_tooltip: "Border Color for the Email Input.",
          initial_value: "rgba(39, 218, 134, 1)",
        },
        {
          key: "signup_email_input_border_color_focused",
          type: "color_picker_rgba",
          label: "Email Input Border Color (focused)",
          label_tooltip: "Border Color for the Focused Email Input.",
          initial_value: "rgba(39, 218, 134, 1)",
        },
        {
          key: "signup_email_input_border_color_filled",
          type: "color_picker_rgba",
          label: "Email Input Border Color (filled)",
          label_tooltip: "Border Color for the Filled Email Input.",
          initial_value: "rgba(39, 218, 134, 1)",
        },
        {
          key: "signup_email_input_placeholder_color",
          type: "color_picker_rgba",
          label: "Email Input Placeholder Color",
          label_tooltip: "Color for the Email Input Placeholder.",
          initial_value: "#9B9B9B",
        },
        {
          key: "signup_email_input_font_tvos",
          type: "tvos_font_selector",
          label_tooltip: "Font for Email Input Text for TvOS.",
          initial_value: "Helvetica-Bold",
        },
        {
          key: "signup_email_input_font_android",
          type: "android_font_selector",
          label_tooltip: "Font for Email Input Text for Android TV.",
          initial_value: "Roboto-Bold",
        },
        {
          key: "signup_email_input_fontsize",
          type: "number_input",
          label_tooltip: "Font Size for Email Input Field.",
          initial_value: "30",
        },
        {
          key: "signup_email_input_fontcolor",
          type: "color_picker_rgba",
          label_tooltip: "Font Color for Email Input Field.",
          initial_value: "#9B9B9B",
        },
      ],
    },
  ],
};

const androidPlatforms = [
  "android",
  "android_for_quickbrick",
  "android_tv_for_quickbrick",
  "amazon_fire_tv_for_quickbrick",
];

const webPlatforms = ["samsung_tv"];

const applePlatforms = ["ios", "ios_for_quickbrick", "tvos_for_quickbrick"];

const tvPlatforms = [
  "tvos_for_quickbrick",
  "android_tv_for_quickbrick",
  "amazon_fire_tv_for_quickbrick",
  "samsung_tv",
];

const api = {
  default: {},
  web: {
    excludedNodeModules: [
      "react-native-dropdownalert",
      "react-native-keyboard-aware-scroll-view",
    ],
  },
  android: {
    class_name: "com.applicaster.reactnative.plugins.APReactNativeAdapter",
    react_packages: ["com.cmcewen.blurview.BlurViewPackage"],
    proguard_rules:
      "-keep public class * extends com.facebook.react.ReactPackage {*;} -keepclasseswithmembers,includedescriptorclasses class * { @com.facebook.react.bridge.ReactMethod <methods>;} -keepclassmembers class *  { @com.facebook.react.uimanager.annotations.ReactProp <methods>; } -keepclassmembers class *  { @com.facebook.react.uimanager.annotations.ReactPropGroup <methods>; }",
  },
};

const project_dependencies = {
  default: [],
  android: [
    {
      "react-native-community_blur":
        "node_modules/@react-native-community/blur/android",
    },
  ],
};

const extra_dependencies = {
  apple: [
    {
      "react-native-blur":
        ":path => 'node_modules/@react-native-community/blur/react-native-blur.podspec'",
    },
  ],
  default: [],
};

const npm_dependencies = {
  default: ["@react-native-community/blur@3.4.1"],
  web: [],
};

const min_zapp_sdk = {
  ios_for_quickbrick: "4.1.0-Dev",
  android_for_quickbrick: "0.1.0-alpha1",
  tvos_for_quickbrick: "4.1.0-Dev",
  android_tv_for_quickbrick: "0.1.0-alpha1",
  amazon_fire_tv_for_quickbrick: "0.1.0-alpha1",
  samsung_tv: "1.2.2",
  lg_tv: "1.0.0",
};

const isApple = R.includes(R.__, applePlatforms);
const iAndroid = R.includes(R.__, androidPlatforms);
const isWeb = R.includes(R.__, webPlatforms);

const withFallback = (obj, platform) => obj[platform] || obj["default"];

function createManifest({ version, platform }) {
  const basePlatform = R.cond([
    [isApple, R.always("apple")],
    [iAndroid, R.always("android")],
    [isWeb, R.always("web")],
  ])(platform);

  const isTV = R.includes(platform, tvPlatforms);

  return {
    ...baseManifest,
    platform,
    dependency_version: version,
    manifest_version: version,
    api: withFallback(api, basePlatform),
    project_dependencies: withFallback(project_dependencies, basePlatform),
    extra_dependencies: withFallback(extra_dependencies, basePlatform),
    min_zapp_sdk: withFallback(min_zapp_sdk, platform),
    npm_dependencies: withFallback(npm_dependencies, basePlatform),
    styles: isTV ? stylesTv : stylesMobile,
    localizations: isTV ? Localizations.tv : Localizations.mobile,
    targets: isTV ? ["tv"] : ["mobile"],
  };
}
module.exports = createManifest;
