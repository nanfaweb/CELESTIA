const express = require("express");
const router = express.Router();
const { pool } = require("../db");

// CREATE a new user profile
router.post("/", async (req, res) => {
  try {
    const { userID, firstName, lastName, bio } = req.body;
    const result = await (await pool).request()
      .input("userID", userID)
      .input("firstName", firstName)
      .input("lastName", lastName)
      .input("bio", bio)
      .query(`
        INSERT INTO UserProfiles (UserID, FirstName, LastName, Bio)
        VALUES (@userID, @firstName, @lastName, @bio);
        SELECT SCOPE_IDENTITY() AS ProfileID;
      `);
    res.status(201).json({ success: true, profileID: result.recordset[0].ProfileID });
  } catch (error) {
    console.error("Error creating user profile:", error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// READ all user profiles
router.get("/", async (req, res) => {
  try {
    const result = await (await pool).request().query("SELECT * FROM UserProfiles");
    res.json({ success: true, data: result.recordset });
  } catch (error) {
    console.error("Error fetching profiles:", error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// READ a user profile by ProfileID
router.get("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const result = await (await pool).request()
      .input("id", id)
      .query("SELECT * FROM UserProfiles WHERE ProfileID = @id");
    if (result.recordset.length === 0) {
      return res.status(404).json({ success: false, message: "Profile not found" });
    }
    res.json({ success: true, data: result.recordset[0] });
  } catch (error) {
    console.error("Error fetching profile:", error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// UPDATE a user profile by ProfileID
router.put("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const { firstName, lastName, bio } = req.body;
    await (await pool).request()
      .input("id", id)
      .input("firstName", firstName)
      .input("lastName", lastName)
      .input("bio", bio)
      .query("UPDATE UserProfiles SET FirstName = @firstName, LastName = @lastName, Bio = @bio WHERE ProfileID = @id");
    res.json({ success: true, message: "Profile updated successfully" });
  } catch (error) {
    console.error("Error updating profile:", error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// DELETE a user profile by ProfileID
router.delete("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    await (await pool).request()
      .input("id", id)
      .query("DELETE FROM UserProfiles WHERE ProfileID = @id");
    res.json({ success: true, message: "Profile deleted successfully" });
  } catch (error) {
    console.error("Error deleting profile:", error);
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
