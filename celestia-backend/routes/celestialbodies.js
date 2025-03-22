const express = require("express");
const router = express.Router();
const { pool } = require("../db");

// CREATE a new celestial body
router.post("/", async (req, res) => {
  try {
    const { name, type, mass, diameter, gravity, orbitalPeriod, description, discoveredBy, discoveryDate, createdByUserID } = req.body;
    const result = await (await pool).request()
      .input("name", name)
      .input("type", type)
      .input("mass", mass)
      .input("diameter", diameter)
      .input("gravity", gravity)
      .input("orbitalPeriod", orbitalPeriod)
      .input("description", description)
      .input("discoveredBy", discoveredBy)
      .input("discoveryDate", discoveryDate)
      .input("createdByUserID", createdByUserID)
      .query(`
        INSERT INTO CelestialBodies 
          (Name, Type, Mass, Diameter, Gravity, OrbitalPeriod, Description, DiscoveredBy, DiscoveryDate, CreatedByUserID)
        VALUES 
          (@name, @type, @mass, @diameter, @gravity, @orbitalPeriod, @description, @discoveredBy, @discoveryDate, @createdByUserID);
        SELECT SCOPE_IDENTITY() AS BodyID;
      `);
    res.status(201).json({ success: true, bodyID: result.recordset[0].BodyID });
  } catch (error) {
    console.error("CREATE celestial body error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// READ all celestial bodies
router.get("/", async (req, res) => {
  try {
    const result = await (await pool).request().query("SELECT * FROM CelestialBodies");
    res.json({ success: true, data: result.recordset });
  } catch (error) {
    console.error("READ celestial bodies error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// READ a single celestial body by BodyID
router.get("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const result = await (await pool).request()
      .input("id", id)
      .query("SELECT * FROM CelestialBodies WHERE BodyID = @id");
    if (result.recordset.length === 0) {
      return res.status(404).json({ success: false, message: "Celestial body not found" });
    }
    res.json({ success: true, data: result.recordset[0] });
  } catch (error) {
    console.error("READ celestial body error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// UPDATE a celestial body by BodyID
router.put("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const { name, type, mass, diameter, gravity, orbitalPeriod, description, discoveredBy, discoveryDate } = req.body;
    await (await pool).request()
      .input("id", id)
      .input("name", name)
      .input("type", type)
      .input("mass", mass)
      .input("diameter", diameter)
      .input("gravity", gravity)
      .input("orbitalPeriod", orbitalPeriod)
      .input("description", description)
      .input("discoveredBy", discoveredBy)
      .input("discoveryDate", discoveryDate)
      .query(`
        UPDATE CelestialBodies 
        SET Name = @name, Type = @type, Mass = @mass, Diameter = @diameter, Gravity = @gravity,
            OrbitalPeriod = @orbitalPeriod, Description = @description, DiscoveredBy = @discoveredBy,
            DiscoveryDate = @discoveryDate
        WHERE BodyID = @id
      `);
    res.json({ success: true, message: "Celestial body updated successfully" });
  } catch (error) {
    console.error("UPDATE celestial body error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// DELETE a celestial body by BodyID
router.delete("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    await (await pool).request()
      .input("id", id)
      .query("DELETE FROM CelestialBodies WHERE BodyID = @id");
    res.json({ success: true, message: "Celestial body deleted successfully" });
  } catch (error) {
    console.error("DELETE celestial body error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
