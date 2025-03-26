const express = require("express");
const cors = require("cors");
require("dotenv").config();
const { pool } = require("./db");
const passport = require("passport");
const session = require("express-session");
const GoogleStrategy = require("passport-google-oauth20").Strategy;
require("dotenv").config();

const usersRouter = require("./routes/users");
const profilesRouter = require("./routes/userprofiles");
const friendsRouter = require("./routes/friends");
const celestialBodiesRouter = require("./routes/celestialbodies");
const userNotesRouter = require("./routes/usernotes");
const userPlanetsRouter = require("./routes/userplanets");
const userPlanetVisibilityRouter = require("./routes/userplanetvisibility");

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware for session handling
app.use(
  session({
    secret: process.env.SESSION_SECRET,
    resave: false,
    saveUninitialized: true,
  })
);
app.use(passport.initialize());
app.use(passport.session());

// Configure Google OAuth Strategy
passport.use(
  new GoogleStrategy(
    {
      clientID: process.env.GOOGLE_CLIENT_ID,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET,
      callbackURL: "/api/users/google/callback",
    },
    (accessToken, refreshToken, profile, done) => {
      // Here, save user info in the database if needed
      return done(null, profile);
    }
  )
);

passport.serializeUser((user, done) => done(null, user));
passport.deserializeUser((obj, done) => done(null, obj));

// Middleware
app.use(cors());
app.use(express.json());

// Mount API routes
app.use("/api/users", usersRouter);
app.use("/api/profiles", profilesRouter);
app.use("/api/friends", friendsRouter);
app.use("/api/celestialbodies", celestialBodiesRouter);
app.use("/api/usernotes", userNotesRouter);
app.use("/api/userplanets", userPlanetsRouter);
app.use("/api/userplanetvisibility", userPlanetVisibilityRouter);

// Test route
app.get("/", (req, res) => {
  res.json({ message: "Celestia API is running." });
});

// Start the server
app.listen(PORT, async () => {
  try {
    await pool;
    console.log(`Server is running on port ${PORT}`);
  } catch (error) {
    console.error("Database connection error:", error);
  }
});
