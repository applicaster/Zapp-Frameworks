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
];

const tv = [
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
