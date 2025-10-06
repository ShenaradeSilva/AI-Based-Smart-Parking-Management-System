import axios from "axios";

const API = axios.create({
  baseURL: "http://localhost:5000", // FastAPI backend
  timeout: 30000, // Increased timeout for file uploads
});

// Request interceptor to add auth token and handle content type dynamically
API.interceptors.request.use((config) => {
  const token = localStorage.getItem("authToken") || localStorage.getItem("token");
  
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  
  // Don't set Content-Type for FormData - let browser set it with boundary
  if (!(config.data instanceof FormData)) {
    config.headers["Content-Type"] = "application/json";
  }
  
  return config;
});

// Response interceptor to handle errors globally
API.interceptors.response.use(
  (response) => {
    return response;
  },
  (error) => {
    console.error("API Error:", error.response?.data || error.message);
    
    if (error.response?.status === 401) {
      // Clear tokens and redirect to login on unauthorized
      localStorage.removeItem("authToken");
      localStorage.removeItem("token");
      window.location.href = "/signin";
    }
    
    return Promise.reject(error);
  }
);

// Helper function for file uploads
export const uploadFile = async (url, formData, onUploadProgress = null) => {
  const config = {
    headers: {
      'Content-Type': 'multipart/form-data',
    },
    timeout: 60000, // Longer timeout for file uploads
  };
  
  if (onUploadProgress) {
    config.onUploadProgress = onUploadProgress;
  }
  
  return API.post(url, formData, config);
};

// Helper function for file updates (PUT requests)
export const updateWithFile = async (url, formData, onUploadProgress = null) => {
  const config = {
    headers: {
      'Content-Type': 'multipart/form-data',
    },
    timeout: 60000,
  };
  
  if (onUploadProgress) {
    config.onUploadProgress = onUploadProgress;
  }
  
  return API.put(url, formData, config);
};

export default API;