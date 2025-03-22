const express = require("express");
const router = express.Router();
const { pool } = require("../db");

// CREATE a new user planet
router.post("/", async (req, res) => {
  try {
    const { userID, name, mass, diameter, gravity, orbitalPeriod, description } = req.body;
    const result = await (await pool).request()
      .input("userID", userID)
      .input("name", name)
      .input("mass", mass)
      .input("diameter", diameter)
      .input("gravity", gravity)
      .input("orbitalPeriod", orbitalPeriod)
      .input("description", description)
      .query(`
        INSERT INTO UserPlanets (UserID, Name, Mass, Diameter, Gravity, OrbitalPeriod, Description)
        VALUES (@userID, @name, @mass, @diameter, @gravity, @orbitalPeriod, @description);
        SELECT SCOPE_IDENTITY() AS UserPlanetID;
      `);
    res.status(201).json({ success: true, userPlanetID: result.recordset[0].UserPlanetID });
  } catch (error) {
    console.error("CREATE user planet error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// READ all user planets
router.get("/", async (req, res) => {
  try {
    const result = await (await pool).request().query("SELECT * FROM UserPlanets");
    res.json({ success: true, data: result.recordset });
  } catch (error) {
    console.error("READ user planets error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// READ a single user planet by UserPlanetID
router.get("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const result = await (await pool).request()
      .input("id", id)
      .query("SELECT * FROM UserPlanets WHERE UserPlanetID = @id");
    if (result.recordset.length === 0) {
      return res.status(404).json({ success: false, message: "User planet not found" });
    }
    res.json({ success: true, data: result.recordset[0] });
  } catch (error) {
    console.error("READ user planet error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// UPDATE a user planet by UserPlanetID
router.put("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const { name, mass, diameter, gravity, orbitalPeriod, description } = req.body;
    await (await pool).request()
      .input("id", id)
      .input("name", name)
      .input("mass", mass)
      .input("diameter", diameter)
      .input("gravity", gravity)
      .input("orbitalPeriod", orbitalPeriod)
      .input("description", description)
      .query(`
        UPDATE UserPlanets 
        SET Name = @name, Mass = @mass, Diameter = @diameter, Gravity = @gravity, OrbitalPeriod = @orbitalPeriod, Description = @description, UpdatedAt = GETDATE()
        WHERE UserPlanetID = @id
      `);
    res.json({ success: true, message: "User planet updated successfully" });
  } catch (error) {
    console.error("UPDATE user planet error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// DELETE a user planet by UserPlanetID
router.delete("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    await (await pool).request()
      .input("id", id)
      .query("DELETE FROM UserPlanets WHERE UserPlanetID = @id");
    res.json({ success: true, message: "User planet deleted successfully" });
  } catch (error) {
    console.error("DELETE user planet error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
