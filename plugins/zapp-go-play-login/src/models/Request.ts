import { AxiosResponse } from "axios";

export interface CreateAccountData {
  email: string;
  password: string;
  publisherId: string;
}
