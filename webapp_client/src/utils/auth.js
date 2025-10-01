// Simple hash function for demo purposes (not secure for production)
export const hashPassword = (password) => {
  let hash = 0;
  for (let i = 0; i < password.length; i++) {
    const char = password.charCodeAt(i);
    hash = ((hash << 5) - hash) + char;
    hash = hash & hash; // Convert to 32-bit integer
  }
  return hash.toString();
};

// Function to validate password against stored signup data
export const validatePasswordMatch = (email, password) => {
  // Retrieve user data from localStorage
  const userData = JSON.parse(localStorage.getItem('userData'));
  
  if (!userData || userData.email !== email) {
    return "No account found with this email";
  }
  
  // Hash the entered password for comparison
  const hashedPassword = hashPassword(password);
  if (userData.password !== hashedPassword) {
    return "Incorrect password";
  }
  
  return ""; // No error
};

// Store user data with hashed password
export const storeUserData = (userData) => {
  const hashedPassword = hashPassword(userData.password);
  const dataToStore = {
    ...userData,
    password: hashedPassword
  };
  localStorage.setItem('userData', JSON.stringify(dataToStore));
};

// Check if user is authenticated
export const isAuthenticated = () => {
  return !!localStorage.getItem('authToken');
};

// Logout user
export const logout = () => {
  localStorage.removeItem('authToken');
};