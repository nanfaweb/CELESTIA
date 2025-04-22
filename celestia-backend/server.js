const express = require("express");
const cors = require("cors");
require("dotenv").config();
const session = require("express-session");
const passport = require("passport");

// Import your DB connection (using pool from db.js)
const { pool } = require("./db");

// Import routers for CRUD operations
const usersRouter = require("./routes/users");
const profilesRouter = require("./routes/userprofiles");
const friendsRouter = require("./routes/friends");
const celestialBodiesRouter = require("./routes/celestialbodies");
const userNotesRouter = require("./routes/usernotes");
const userPlanetsRouter = require("./routes/userplanets");
const userPlanetVisibilityRouter = require("./routes/userplanetvisibility");
const userInfoRoutes = require('./routes/userinfo');

// Import new auth router
const authRouter = require("./routes/auth");

const app = express();
const PORT = process.env.PORT || 3001; // Use a different port if needed

// Middleware for session handling and Passport initialization
app.use(
  session({
    secret: process.env.SESSION_SECRET || "defaultsecret",
    resave: false,
    saveUninitialized: true,
  })
);
app.use(passport.initialize());
app.use(passport.session());

// Middleware for parsing JSON and CORS
app.use(cors());
app.use(express.json());

// Mount API routes for CRUD operations
app.use("/api/users", usersRouter);
app.use("/api/profiles", profilesRouter);
app.use("/api/friends", friendsRouter);
app.use("/api/celestial-bodies", celestialBodiesRouter);
app.use("/api/user-notes", userNotesRouter);
app.use("/api/user-planets", userPlanetsRouter);
app.use("/api/user-planet-visibility", userPlanetVisibilityRouter);
app.use('/api', userInfoRoutes);

// Mount Auth routes separately under /api/auth
app.use("/api/auth", authRouter);

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
