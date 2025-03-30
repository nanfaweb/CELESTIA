const express = require("express");
const router = express.Router();
const { pool } = require("../db"); // Assumes you have a db.js file that exports the connection pool
const passport = require("passport");
const session = require("express-session");
require("dotenv").config();

// CREATE a new user
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

    // Store password as plain text (for testing)
    const result = await (await pool).request()
      .input("username", username)
      .input("email", email)
      .input("password", password) // No hashing
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

// Login registered users
router.post("/login", async (req, res) => {
  try {
    console.log("Login request received:", req.body); // Log request data

    const { email, password } = req.body;

    const result = await (await pool).request()
      .input("email", email)
      .query("SELECT * FROM Users WHERE Email = @email");

    console.log("Database query result:", result.recordset); // Log database response

    if (result.recordset.length === 0) {
      console.log("User not found for email:", email);
      return res.status(401).json({ success: false, message: "User not found" });
    }

    const user = result.recordset[0];
    console.log("Stored password:", user.PasswordHash, "Entered password:", password);

    if (password !== user.PasswordHash) {
      console.log("Incorrect password attempt for user:", email);
      return res.status(401).json({ success: false, message: "Incorrect password" });
    }

    console.log("Login successful for user:", email);
    res.json({ success: true, message: "Login successful", userID: user.UserID });

  } catch (error) {
    console.error("Error logging in:", error);
    res.status(500).json({ success: false, message: error.message });
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

router.get(
  "/google",
  passport.authenticate("google", { scope: ["profile", "email"] })
);

router.get(
  "/google/callback",
  passport.authenticate("google", { failureRedirect: "/login" }),
  (req, res) => {
    // Redirect to frontend with token/session
    console.log("Hello?");
    res.redirect(`http://localhost:3000/dashboard`);
  }
);

router.get("/logout", (req, res) => {
  req.logout(() => {
    res.redirect("/");
  });
});


module.exports = router;
