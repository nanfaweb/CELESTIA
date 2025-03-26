import { useState } from "react";
import { signIn } from "next-auth/react"; // if using NextAuth later

export default function Auth() {
  // Mode: either "signup" or "login"
  const [mode, setMode] = useState("signup");
  const [formData, setFormData] = useState({ username: "", email: "", password: "" });
  const [error, setError] = useState("");

  // Basic regex for email validation
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
    setError("");
  };

  const validateForm = () => {
    if (!emailRegex.test(formData.email)) {
      setError("Please enter a valid email address.");
      return false;
    }
    if (formData.password.length < 8) {
      setError("Password must be at least 8 alphanumeric characters.");
      return false;
    }
    if (mode === "signup" && formData.username.trim() === "") {
      setError("Username is required for sign up.");
      return false;
    }
    return true;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!validateForm()) return;

    if (mode === "signup") {
      try {
        const response = await fetch("http://localhost:3001/api/users", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify(formData),
        });
        if (!response.ok) {
          throw new Error("Sign up failed");
        }
        const data = await response.json();
        alert("Sign up successful! New user ID: " + data.userID);
      } catch (err) {
        console.error(err);
        setError("Failed to sign up. Please try again.");
      }
    } else {
      // Login logic can be implemented similarly
      try {
        const response = await fetch("http://localhost:3001/api/login", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({ email: formData.email, password: formData.password }),
        });
        if (!response.ok) {
          throw new Error("Login failed");
        }
        const data = await response.json();
        alert("Login successful!");
      } catch (err) {
        console.error(err);
        setError("Failed to log in. Please try again.");
      }
    }
  };

  const handleGoogleSignIn = () => {
    // For NextAuth, you could use signIn('google')
    window.location.href = "http://localhost:3001/api/auth/google";
  };

  return (
    <div className="auth-container">
      <div className="auth-box">
        <h1 className="auth-header">CELESTIA</h1>
        <div className="auth-toggle">
          <button onClick={() => setMode("signup")} className={mode === "signup" ? "active" : ""}>
            Sign Up
          </button>
          <button onClick={() => setMode("login")} className={mode === "login" ? "active" : ""}>
            Login
          </button>
        </div>
        {error && <p style={{ color: "#ff6b6b", marginBottom: "1rem" }}>{error}</p>}
        <form onSubmit={handleSubmit}>
          {mode === "signup" && (
            <input
              type="text"
              name="username"
              placeholder="Username"
              onChange={handleChange}
              required
            />
          )}
          <input type="email" name="email" placeholder="Email" onChange={handleChange} required />
          <input type="password" name="password" placeholder="Password" onChange={handleChange} required />
          <button type="submit" className="auth-button">
            {mode === "signup" ? "Sign Up" : "Login"}
          </button>
        </form>
        <div className="divider">or</div>
        <button type="button" className="google-button" onClick={handleGoogleSignIn}>
          Sign in with Google
        </button>
      </div>
    </div>
  );
}
