const express = require("express");
const router = express.Router();
const { pool } = require("../db");

// CREATE a new visibility record
router.post("/", async (req, res) => {
  try {
    const { userPlanetID, friendID, canView } = req.body;
    const result = await (await pool).request()
      .input("userPlanetID", userPlanetID)
      .input("friendID", friendID)
      .input("canView", canView)
      .query(`
        INSERT INTO UserPlanetVisibility (UserPlanetID, FriendID, CanView)
        VALUES (@userPlanetID, @friendID, @canView);
        SELECT SCOPE_IDENTITY() AS VisibilityID;
      `);
    res.status(201).json({ success: true, visibilityID: result.recordset[0].VisibilityID });
  } catch (error) {
    console.error("CREATE visibility error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// READ all visibility records
router.get("/", async (req, res) => {
  try {
    const result = await (await pool).request().query("SELECT * FROM UserPlanetVisibility");
    res.json({ success: true, data: result.recordset });
  } catch (error) {
    console.error("READ visibility records error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// READ a single visibility record by VisibilityID
router.get("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const result = await (await pool).request()
      .input("id", id)
      .query("SELECT * FROM UserPlanetVisibility WHERE VisibilityID = @id");
    if (result.recordset.length === 0) {
      return res.status(404).json({ success: false, message: "Visibility record not found" });
    }
    res.json({ success: true, data: result.recordset[0] });
  } catch (error) {
    console.error("READ visibility record error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// UPDATE a visibility record by VisibilityID
router.put("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const { canView } = req.body;
    await (await pool).request()
      .input("id", id)
      .input("canView", canView)
      .query("UPDATE UserPlanetVisibility SET CanView = @canView WHERE VisibilityID = @id");
    res.json({ success: true, message: "Visibility record updated successfully" });
  } catch (error) {
    console.error("UPDATE visibility record error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// DELETE a visibility record by VisibilityID
router.delete("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    await (await pool).request()
      .input("id", id)
      .query("DELETE FROM UserPlanetVisibility WHERE VisibilityID = @id");
    res.json({ success: true, message: "Visibility record deleted successfully" });
  } catch (error) {
    console.error("DELETE visibility record error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
