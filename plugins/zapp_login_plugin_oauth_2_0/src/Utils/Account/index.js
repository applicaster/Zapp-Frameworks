import { Alert } from "react-native";
import { isWebBasedPlatform } from "../Platform";

export function showAlert(title, message) {
  isWebBasedPlatform
    ? window.alert(`${title} \n${message}`)
    : Alert.alert(title, message);
}

export function isValidEmail(email) {
  const regex = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
  return !!email && regex.test(email);
}

function isValidUserName(name) {
  return !!name && name.length > 0;
}

function isValidConfirmationPassword(password, passwordConfirmation) {
  return !!password && !!passwordConfirmation && (password === passwordConfirmation);
}

function isValidPasswordLength(password) {
  return !!password && password.length >= 8;
}

function isValidPasswordCharacters(password) {
  const regex = /^(?=.*[\d])(?=.*[A-Z])(?=.*[a-z])(?=.*[!@#$%^&*])[\w!@#$%^&*]{8,}$/;
  return regex.test(password);
}

function isValidPassword(password) {
  return isValidPasswordLength(password) && isValidPasswordCharacters(password)
}

function isValidToken(token) {
  return !!token && token.length > 0
}

export function validateSignUpData({ fullName, email, password, passwordConfirmation }, screenLocalizations) {
  if (!isValidUserName(fullName)) {
    return new Error(screenLocalizations.signup_name_validation_error);
  } else if (!isValidEmail(email)) {
    return new Error(screenLocalizations.login_email_validation_error);
  } else if (!isValidPassword(password)) {
    return new Error(screenLocalizations.signup_password_validation_error);
  } else if (!isValidConfirmationPassword(password, passwordConfirmation)) {
    return new Error(screenLocalizations.signup_password_confirmation_validation_error);
  }
}

export function validateNewPassword({ token, password, passwordConfirmation }, screenLocalizations) {
  if (!isValidToken(token)) {
    return new Error(screenLocalizations.new_password_token_validation_error);
  } else if (!isValidPassword(password)) {
    return new Error(screenLocalizations.signup_password_validation_error);
  } else if (!isValidConfirmationPassword(password, passwordConfirmation)) {
    return new Error(screenLocalizations.signup_password_confirmation_validation_error);
  }
}
