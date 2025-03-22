const express = require('express');
const cors = require('cors');
require('dotenv').config();
const { pool } = require('./db');
const usersRouter = require('./routes/users');
const profilesRouter = require('./routes/userProfiles');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Mount API routes for Users and UserProfiles
app.use('/api/users', usersRouter);
app.use('/api/userprofiles', profilesRouter);

// Simple test route
app.get('/', (req, res) => {
  res.json({ message: "Celestia API is running." });
});

// Start the server
app.listen(PORT, async () => {
  try {
    await pool; // Ensures the database connection is established
    console.log(`Server is running on port ${PORT}`);
  } catch (error) {
    console.error("Database connection error:", error);
  }
});
