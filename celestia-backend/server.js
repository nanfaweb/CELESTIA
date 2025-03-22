const express = require("express");
const cors = require("cors");
require("dotenv").config();
const { pool } = require("./db");

const usersRouter = require("./routes/users");
const profilesRouter = require("./routes/userprofiles");
const friendsRouter = require("./routes/friends");
const celestialBodiesRouter = require("./routes/celestialbodies");
const userNotesRouter = require("./routes/usernotes");
const userPlanetsRouter = require("./routes/userplanets");
const userPlanetVisibilityRouter = require("./routes/userplanetvisibility");

const app = express();
const PORT = process.env.PORT || 3000;

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
