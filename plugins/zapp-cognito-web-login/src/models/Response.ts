export interface LoginData {
  client_id?: string;
  access_token?: string;
  expires_in?: number;
  refresh_token?: string;
  user_email?: string;
  user_first_name?: string;
  user_last_name?: string;
  selligent_id?: string;
  id_token?: string;
}

export interface LoginDataRefresh {
  client_id: string;
  access_token: string;
  expires_in: number;
  refresh_token: string;
  user_email: string;
  user_first_name: string;
  user_last_name: string;
  selligent_id: string;
}

export const LoginDataKeys = {
  client_id: "client_id",
  access_token: "access_token",
  expires_in: "expires_in",
  refresh_token: "refresh_token",
  user_email: "user_email",
  user_first_name: "user_first_name",
  user_last_name: "user_last_name",
  selligent_id: "selligent_id",
  id_token: "id_token",
};
