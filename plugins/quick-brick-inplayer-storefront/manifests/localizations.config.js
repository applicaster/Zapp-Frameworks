const common = [
  // Messages - general
  {
    key: "video_stream_exception_message",
    label: "Message in case video url is empty",
    initial_value: "Video stream in not available. Please try again later",
  },
  {
    key: "general_error_message",
    label: "General error message",
    initial_value: "Something went wrong. Please try again later",
  },
];

const mobile = [
  // StoreFront screen
  {
    key: "payment_screen_title_text",
    label: "Payment screen title",
    initial_value: "Choose Your Subscription",
  },
  {
    key: "restore_purchases_text",
    label: "Restore purchases description",
    initial_value: "Purchased already a subscription?",
  },
  {
    key: "restore_purchases_link",
    label: "Restore purchases text",
    initial_value: "Restore",
  },
  {
    key: "terms_of_use_instructions_text",
    label: "Payment terms of use instruction",
    initial_value:
      "By making a selection and completing this transaction, you verify that you are at least 18 years old and agree to the",
  },
  {
    key: "terms_of_use_link_text",
    label: "Payment terms of use text",
    initial_value: "terms of use.",
  },
  {
    key: "terms_of_use_link",
    label: "Payment terms of use link",
    initial_value: "https://www.google.com",
  },
];

const tv = [
  // Subscriber agreement screen
  {
    key: "privacy_main_title_text",
    label: "Agreement and privacy screen title",
    initial_value: "Subscriber Agreement & Privacy Policy",
  },
  {
    key: "privacy_text",
    label: "Agreement and privacy text",
    initial_value:
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque sit amet nunc dui. Sed nec dignissim erat. Praesent molestie, odio et lacinia dapibus, lacus felis interdum justo, a viverra eros mauris vel nibh. Nullam consequat urna at lorem interdum, non mattis elit interdum. Cras libero erat, mattis ut mattis in, ornare ut ante. Duis id mi condimentum elit sagittis scelerisque. Duis facilisis vel lectus eu fermentum. Etiam venenatis fermentum felis nec ornare. Nullam pretium iaculis ligula sed accumsan.\n\n\nDonec id libero sit amet ligula cursus tempor. Donec urna felis, vestibulum id fringilla in, elementum ac diam. Nunc pretium, ligula ac accumsan accumsan, ipsum ante tristique nisi, et dictum dui arcu eu ex. Duis vel lectus quis nisl fringilla dictum. Praesent vulputate justo ligula, at commodo lorem sodales sed. Cras quis rhoncus ante. Nunc ultricies orci eget purus elementum, eget posuere elit semper. Suspendisse quis dignissim elit, eget dictum sem. Sed in nisl dui. Curabitur at sapien consectetur, lacinia turpis vitae, pharetra nisl. Nullam accumsan odio orci, quis elementum ex luctus id. Cras nec eros orci. Vestibulum eget convallis lectus. Donec eu lorem at purus elementum tempo.",
  },

  // StoreFront screen
  {
    key: "subscription_default_title_text",
    label: "Subscription default title",
    initial_value: "Choose Your Subscription",
  },
  {
    key: "policy_agreement_text",
    label: "Policy agreement text",
    initial_value:
      "By clicking “Subscribe” or “Buy” below, you also agree to the [Client’s App Name] Agreement and acknowledge that you have read our Privacy Policy",
  },
  {
    key: "subscriber_agreement_and_privacy_policy_text",
    label: "Subscriber Agreement and Privacy policy text",
    initial_value:
      "[Client’s Name App] Subscriber Agreement and Privacy Policy",
  },

  // Action buttons
  {
    key: "restore_purchase_action_button_text",
    label: "Restore purchases button title",
    initial_value: "Restore",
  },
  {
    key: "payment_option_action_text_type_buy",
    label: "Buy button title",
    initial_value: "Buy",
  },
  {
    key: "payment_option_action_text_type_subscribe",
    label: "Subscribe button title",
    initial_value: "Subscribe",
  },
];

const Localizations = {
  mobile: {
    fields: [...common, ...mobile],
  },
  tv: {
    fields: [...common, ...tv],
  },
};

module.exports = Localizations;
