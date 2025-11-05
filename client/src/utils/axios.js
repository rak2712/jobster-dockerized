import axios from "axios";
import { clearStore } from "../features/user/userSlice";
import { getUserFromLocalStorage } from "./localStorage";

const customFetch = axios.create({
  baseURL: "/api/v1",
});

customFetch.interceptors.request.use((config) => {
  const user = getUserFromLocalStorage();
  if (user) {
    config.headers.common["Authorization"] = `Bearer ${user.token}`;
  }
  return config;
});

customFetch.interceptors.response.use(
  (response) => {
    console.log("✅ API Response", response);
  },
  (error) => {
    console.error("❌ API Error:", error);
    if (error.response) {
      const { status } = error.response;

      if (status === 401) {
        console.warn("⚠️⚠️ Unauthorized logging out...");
        localStorage.removeItem("user");
        window.location.href = "/login";
      }
    }
  }
);

export const checkForUnauthorizedResponse = (error, thunkAPI) => {
  if (error.response.status === 401) {
    thunkAPI.dispatch(clearStore());
    return thunkAPI.rejectWithValue("Unauthorized! Logging Out...");
  }
  return thunkAPI.rejectWithValue(error.response.data.msg);
};

export default customFetch;
