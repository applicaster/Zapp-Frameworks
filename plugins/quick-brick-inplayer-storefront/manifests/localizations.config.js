const common = [
  // Fields
  {
    key: "fields_email_text",
    label: "Email field placeholder",
    initial_value: "E-mail",
  },
  {
    key: "fields_password_text",
    label: "Password field placeholder",
    initial_value: "Password",
  },
  {
    key: "fields_name_text",
    label: "Name field placeholder",
    initial_value: "Enter your name",
  },

  // Action buttons
  {
    key: "action_button_login_text",
    label: "Login button title",
    initial_value: "LOG IN",
  },
  {
    key: "action_button_signup_text",
    label: "Signup button title",
    initial_value: "SIGN UP",
  },

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

  // Messages - signup
  {
    key: "signup_title_error_text",
    label: "Error signup title",
    initial_value: "Sign-up failed",
  },

  // Messages - login
  {
    key: "login_title_error_text",
    label: "Error login title",
    initial_value: "Login failed",
  },

  // Messages - logout
  {
    key: "logout_title_succeed_text",
    label: "Successful logout title",
    initial_value: "Successfully Logged Out",
  },
  {
    key: "logout_title_fail_text",
    label: "Error logout title",
    initial_value: "Logout Failed",
  },

  // Messages - reset password
  {
    key: "reset_password_success_title",
    label: "Successful password reset title",
    initial_value: "Set New Password Success",
  },
  {
    key: "reset_password_success_text",
    label: "Successful password reset message",
    initial_value: "Your password was successfully updated",
  },
  {
    key: "reset_password_error_title",
    label: "Password reset error title",
    initial_value: "Set New Password",
  },
  {
    key: "reset_password_error_text",
    label: "Password reset error message",
    initial_value: "New password could not be set. Please try again.",
  },

  // Messages - request password
  {
    key: "request_password_success_title",
    label: "Successful password request title",
    initial_value: "Request Password Success",
  },
  {
    key: "request_password_error_title",
    label: "Password request error title",
    initial_value: "Request Password Fail",
  },
  {
    key: "request_password_error_text",
    label: "Password request error message",
    initial_value: "Can not request password",
  },

  // Validation - title
  {
    key: "login_title_validation_error",
    label: "Login validation error title",
    initial_value: "Login form issue",
  },
  {
    key: "signup_title_validation_error",
    label: "Signup validation error title",
    initial_value: "Sign Up form issue",
  },
  {
    key: "new_password_title_validation_error",
    label: "New password validation error title",
    initial_value: "Set New Password form issue",
  },

  // Validation - message
  {
    key: "login_email_validation_error",
    label: "Error message for not valid EMAIL",
    initial_value: "Email is not valid",
  },
  {
    key: "signup_name_validation_error",
    label: "Error message for not valid NAME",
    initial_value: "Name can not be empty",
  },
  {
    key: "signup_password_validation_error",
    label: "Error message for not valid PASSWORD",
    initial_value:
      "Password must be at least 8 characters and contain one lower case, one upper case, one special character and one number",
  },
  {
    key: "signup_password_confirmation_validation_error",
    label: "Error message for not valid PASSWORD CONFIRMATION",
    initial_value: "Password not equal confirmation password",
  },
  {
    key: "new_password_token_validation_error",
    label: "Error message for not valid TOKEN",
    initial_value: "Token should not be empty",
  },
];

const mobile = [
  // Header
  {
    key: "title_font_text",
    label: "Text title",
    initial_value: "InPlayer",
  },
  {
    key: "back_button_text",
    label: "Back button title",
    initial_value: "Back",
  },

  // Fields
  {
    key: "fields_set_new_password_text",
    label: "New password field placeholder",
    initial_value: "New password",
  },
  {
    key: "fields_password_confirmation_text",
    label: "Password confirmation field placeholder",
    initial_value: "Password Confirmation",
  },
  {
    key: "fields_token_text",
    label: "Token field placeholder",
    initial_value: "Token",
  },

  // Login screen
  {
    key: "forgot_password_text",
    label: "Forgot password text",
    initial_value: "Forgotten your Username or Password?",
  },
  {
    key: "create_account_link_text",
    label: "Create account text",
    initial_value: "No user? Sign Up!",
  },

  // Action buttons
  {
    key: "action_button_forgot_password_text",
    label: "Request password button title",
    initial_value: "REQUEST PASSWORD",
  },
  {
    key: "action_button_set_new_password_text",
    label: "Set new password button title",
    initial_value: "SET NEW PASSWORD",
  },

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

  // Account screen
  {
    key: "login_title_text",
    label: "Login title",
    initial_value: "Welcome To The App",
  },
  {
    key: "main_description_text",
    label: "Main description text",
    initial_value:
      "Helping companies maximize any cloud infrastructure, reduce costs, increase engagement, and significantly improve time to market and speed of ongoing innovation.",
  },
  {
    key: "optional_instructions_1_text",
    label: "Optional instructions 1",
    initial_value: "Optional Instructions",
  },
  {
    key: "optional_instructions_2_text",
    label: "Optional instructions 2",
    initial_value: "Optional Instructions",
  },

  // Signup screen
  {
    key: "signup_title_text",
    label: "Signup title",
    initial_value: "Registration",
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
