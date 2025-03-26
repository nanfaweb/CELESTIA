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
    // Here, in production, hash the password before storing!
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

// READ all users
router.get("/", async (req, res) => {
  try {
    const poolConn = await pool; // Ensure connection is awaited
    const result = await poolConn.request().query("SELECT * FROM Users");
    res.json(result.recordset);
  } catch (error) {
    console.error("Error fetching users:", error);
    res.status(500).json({ error: "Internal Server Error" });
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
