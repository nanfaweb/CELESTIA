// users.js
const express = require("express");
const router = express.Router();
const { pool } = require("../db"); // Assumes you have a db.js file that exports the connection pool
const passport = require("passport");
const session = require("express-session");
const crypto = require("crypto"); // For generating unique dummy passwords
require("dotenv").config();

// CREATE a new user (manual signup)
router.post("/", async (req, res) => {
  try {
    const { username, email, password } = req.body;

    // Validate email format
    if (!email.includes("@") || (!email.includes(".com") && !email.includes("."))) {
      return res.status(400).json({ success: false, message: "Invalid email format" });
    }

    // Validate password (at least 8 characters, alphanumeric)
    if (!password || password.length < 8 || !/\d/.test(password) || !/[a-zA-Z]/.test(password)) {
      return res.status(400).json({ success: false, message: "Password must be at least 8 alphanumeric characters" });
    }

    // For testing, storing the password as plain text (NOT recommended for production)
    const result = await (await pool).request()
      .input("username", username)
      .input("email", email)
      .input("password", password)
      .query(`
        INSERT INTO Users (Username, Email, PasswordHash)
        VALUES (@username, @email, @password);
        SELECT SCOPE_IDENTITY() AS UserID;
      `);

    res.status(201).json({ success: true, userID: result.recordset[0].UserID });
  } catch (error) {
    console.error("Error creating user:", error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// Login registered users (manual login)
router.post("/login", async (req, res) => {
  try {
    console.log("Login request received:", req.body);

    const { email, password } = req.body;
    const poolConn = await pool;
    const result = await poolConn.request()
      .input("email", email)
      .query("SELECT * FROM Users WHERE Email = @email");

    console.log("Database query result:", result.recordset);

    if (result.recordset.length === 0) {
      console.log("User not found for email:", email);
      return res.status(401).json({ success: false, message: "User not found" });
    }

    const user = result.recordset[0];

    // If the user was created via Google OAuth then manual login is not allowed.
    if (user.PasswordHash.startsWith("GOOGLE_AUTH_")) {
      console.log("Attempted manual login on a Google user account:", email);
      return res.status(401).json({
        success: false,
        message: "Use Google Sign-In for this account."
      });
    }

    console.log("Stored password:", user.PasswordHash, "Entered password:", password);

    if (password !== user.PasswordHash) {
      console.log("Incorrect password attempt for user:", email);
      return res.status(401).json({ success: false, message: "Incorrect password" });
    }

    console.log("Login successful for user:", email);
    res.json({
      success: true,
      message: "Login successful",
      userID: user.UserID,
      redirectUrl: "http://localhost:3000/dashboard"
    });
  } catch (error) {
    console.error("Error logging in:", error);
    res.status(500).json({ success: false, message: error.message });
  }
});

router.get("/", async (req, res) => {
  try {
      const result = await (await pool).request().query("SELECT Username AS name FROM Users");
      res.json(result.recordset);
  } catch (error) {
      console.error("Error fetching users:", error);
      res.status(500).json({ success: false, message: "Failed to fetch users" });
  }
});

// READ a single user by ID
router.get("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const result = await (await pool).request()
      .input("id", id)
      .query("SELECT * FROM Users WHERE UserID = @id");
    if (result.recordset.length === 0) {
      return res.status(404).json({ success: false, message: "User not found" });
    }
    res.json({ success: true, data: result.recordset[0] });
  } catch (error) {
    console.error("Error fetching user:", error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// UPDATE a user by ID
router.put("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const { username, email } = req.body;
    await (await pool).request()
      .input("id", id)
      .input("username", username)
      .input("email", email)
      .query("UPDATE Users SET Username = @username, Email = @email WHERE UserID = @id");
    res.json({ success: true, message: "User updated successfully" });
  } catch (error) {
    console.error("Error updating user:", error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// DELETE a user by ID
router.delete("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    await (await pool).request()
      .input("id", id)
      .query("DELETE FROM Users WHERE UserID = @id");
    res.json({ success: true, message: "User deleted successfully" });
  } catch (error) {
    console.error("Error deleting user:", error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// Google OAuth routes
router.get(
  "/google",
  passport.authenticate("google", { scope: ["profile", "email"] })
);

router.get(
  "/google/callback",
  passport.authenticate("google", { failureRedirect: "/login" }),
  (req, res) => {
    // Redirect to the dashboard after successful Google authentication
    console.log("Google OAuth successful for user:", req.user);
    res.redirect("http://localhost:3000/dashboard");
  }
);

router.get("/logout", (req, res) => {
  req.logout(() => {
    res.redirect("/");
  });
});

// Configure Google OAuth Strategy
const GoogleStrategy = require("passport-google-oauth20").Strategy;
passport.use(
  new GoogleStrategy(
    {
      clientID: process.env.GOOGLE_CLIENT_ID,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET,
      callbackURL: "/api/users/google/callback",
    },
    async (accessToken, refreshToken, profile, done) => {
      try {
        const email = profile.emails[0].value;
        const username = profile.displayName || profile.name.givenName || email;
        // Generate a dummy password with a unique value for each Google user
        const dummyPassword = "GOOGLE_AUTH_" + crypto.randomUUID();

        const poolConn = await pool;
        const existingUserResult = await poolConn.request()
          .input("email", email)
          .query("SELECT * FROM Users WHERE Email = @email");

        if (existingUserResult.recordset.length === 0) {
          // Insert a new Google user with the generated dummy password
          await poolConn.request()
            .input("username", username)
            .input("email", email)
            .input("password", dummyPassword)
            .query(`
              INSERT INTO Users (Username, Email, PasswordHash)
              VALUES (@username, @email, @password)
            `);
        }

        return done(null, profile);
      } catch (err) {
        console.error("Error during Google OAuth:", err);
        return done(err, null);
      }
    }
  )
);

module.exports = router;