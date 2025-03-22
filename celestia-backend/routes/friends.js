const express = require("express");
const router = express.Router();
const { pool } = require("../db");

// CREATE a new friendship
router.post("/", async (req, res) => {
  try {
    const { userID, friendID, status } = req.body;
    const result = await (await pool).request()
      .input("userID", userID)
      .input("friendID", friendID)
      .input("status", status)
      .query(`
        INSERT INTO Friends (UserID, FriendID, Status, RequestedAt)
        VALUES (@userID, @friendID, @status, GETDATE());
        SELECT SCOPE_IDENTITY() AS FriendshipID;
      `);
    res.status(201).json({ success: true, friendshipID: result.recordset[0].FriendshipID });
  } catch (error) {
    console.error("CREATE friendship error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// READ all friendships
router.get("/", async (req, res) => {
  try {
    const result = await (await pool).request().query("SELECT * FROM Friends");
    res.json({ success: true, data: result.recordset });
  } catch (error) {
    console.error("READ friendships error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// READ a single friendship by ID
router.get("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const result = await (await pool).request()
      .input("id", id)
      .query("SELECT * FROM Friends WHERE FriendshipID = @id");
    if (result.recordset.length === 0) {
      return res.status(404).json({ success: false, message: "Friendship not found" });
    }
    res.json({ success: true, data: result.recordset[0] });
  } catch (error) {
    console.error("READ friendship error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// UPDATE a friendship by ID (e.g., to update Status or RespondedAt)
router.put("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const { status, respondedAt } = req.body;
    await (await pool).request()
      .input("id", id)
      .input("status", status)
      .input("respondedAt", respondedAt)
      .query("UPDATE Friends SET Status = @status, RespondedAt = @respondedAt WHERE FriendshipID = @id");
    res.json({ success: true, message: "Friendship updated successfully" });
  } catch (error) {
    console.error("UPDATE friendship error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// DELETE a friendship by ID
router.delete("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    await (await pool).request()
      .input("id", id)
      .query("DELETE FROM Friends WHERE FriendshipID = @id");
    res.json({ success: true, message: "Friendship deleted successfully" });
  } catch (error) {
    console.error("DELETE friendship error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
