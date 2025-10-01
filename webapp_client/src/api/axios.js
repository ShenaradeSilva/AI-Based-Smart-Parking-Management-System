import axios from "axios";

const API = axios.create({
  baseURL: "http://localhost:5000", // FastAPI backend
  headers: {
    "Content-Type": "application/json",
  },
});

// Attach token if present
API.interceptors.request.use((config) => {
  const token = localStorage.getItem("authToken"); // use the same key as SignIn
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export default API;
