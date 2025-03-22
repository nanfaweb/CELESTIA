import { useState } from "react";

export default function SignUp() {
  const [formData, setFormData] = useState({ username: "", email: "", password: "" });

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    alert(`Username: ${formData.username}\nEmail: ${formData.email}\nPassword: ${formData.password}`);
  };

  return (
    <div className="container">
      <div className="form-container">
        <h1 className="glass-header">CELESTIA</h1>
        <h2 className="form-title">Sign Up</h2>
        <form onSubmit={handleSubmit}>
          <input
            type="text"
            name="username"
            placeholder="Username"
            onChange={handleChange}
            required
          />
          <input
            type="email"
            name="email"
            placeholder="Email"
            onChange={handleChange}
            required
          />
          <input
            type="password"
            name="password"
            placeholder="Password"
            onChange={handleChange}
            required
          />
          <button type="submit" className="submit-button">
            Sign Up
          </button>
        </form>
        <div className="or-text">or</div>
        <button type="button" className="google-button">
          Sign in with Google
        </button>
      </div>
    </div>
  );
}
