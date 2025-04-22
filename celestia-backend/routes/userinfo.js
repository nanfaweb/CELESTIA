const express = require('express');
const router = express.Router();
const { pool } = require('../db');

// GET logged-in user's username (based on email or session if implemented)
router.get('/get-username', async (req, res) => {
  try {
    const email = req.query.email;
    if (!email) return res.status(400).json({ success: false, message: "Missing email" });

    const result = await (await pool).request()
      .input("email", email)
      .query("SELECT Username FROM Users WHERE Email = @email");

    if (result.recordset.length === 0) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    const username = result.recordset[0].Username;
    res.json({ success: true, username });
  } catch (error) {
    console.error("Error fetching username:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

module.exports = router;