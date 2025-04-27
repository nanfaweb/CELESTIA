const express = require("express");
const passport = require("passport");
const GoogleStrategy = require("passport-google-oauth20").Strategy;
const crypto = require("crypto");
const { pool } = require("../db");
require("dotenv").config();

const router = express.Router();

// Configure Google OAuth strategy
passport.use(
  new GoogleStrategy(
    {
      clientID: process.env.GOOGLE_CLIENT_ID,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET,
      callbackURL: "/api/auth/google/callback",
    },
    async (accessToken, refreshToken, profile, done) => {
      try {
        if (!profile.emails || !profile.emails[0]) {
          console.error("Google profile does not contain an email.");
          return done(new Error("Google profile does not contain an email"), null);
        }

        const email = profile.emails[0].value;
        const username = profile.displayName || profile.name.givenName;

        // Check if the user already exists in the database
        const existingUserResult = await (await pool).request()
          .input("email", email)
          .query("SELECT * FROM Users WHERE Email = @email");

        if (existingUserResult.recordset.length === 0) {
          // Register the user if they don't exist
          const dummyPassword = "GOOGLE_AUTH_" + crypto.randomUUID();

          await (await pool).request()
            .input("username", username)
            .input("email", email)
            .input("password", dummyPassword)
            .query(`
              INSERT INTO Users (Username, Email, PasswordHash)
              VALUES (@username, @email, @password);
            `);

          console.log("Google user registered.");
        }

        console.log(`Google OAuth successful for user: ${email}`);
        return done(null, profile);
      } catch (err) {
        console.error("Error during Google OAuth:", err);
        return done(err, null);
      }
    }
  )
);

// Serialize and deserialize user for session management
passport.serializeUser((user, done) => done(null, user));
passport.deserializeUser((obj, done) => done(null, obj));

// Route to initiate Google OAuth
router.get("/google", passport.authenticate("google", { scope: ["profile", "email"] }));

// Google OAuth callback route
router.get(
  "/google/callback",
  passport.authenticate("google", { failureRedirect: "/login" }),
  async (req, res) => {
    const profile = req.user;
    const email = profile.emails[0].value;

    try {
      const poolConn = await pool;
      // Check if the user exists in the database
      const checkResult = await poolConn
        .request()
        .input("email", email)
        .query("SELECT * FROM Users WHERE Email = @email");

      let userID;
      if (checkResult.recordset.length === 0) {
        // Register the user if they don't exist
        const dummyPassword = "GOOGLE_AUTH_" + crypto.randomUUID();
        const insertResult = await poolConn
          .request()
          .input("username", profile.displayName || profile.name.givenName || "GoogleUser")
          .input("email", email)
          .input("password", dummyPassword)
          .query(`
            INSERT INTO Users (Username, Email, PasswordHash)
            VALUES (@username, @email, @password);
            SELECT SCOPE_IDENTITY() AS UserID;
          `);
        userID = insertResult.recordset[0].UserID;
        console.log("Google user registered.");
      } else {
        userID = checkResult.recordset[0].UserID;
      }

      // Redirect to the frontend with the user's email and userID
      res.redirect(`http://localhost:3000/LandingPage/index.html?email=${encodeURIComponent(email)}&userID=${userID}`);
    } catch (err) {
      console.error("Error during Google sign-in:", err);
      res.redirect("/login");
    }
  }
);

// Logout route
router.get("/logout", (req, res) => {
  req.logout(() => {
    res.redirect("/");
  });
});

module.exports = router;