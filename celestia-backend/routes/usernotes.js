const express = require("express");
const router = express.Router();
const { pool } = require("../db");

// CREATE a new note
router.post("/", async (req, res) => {
  try {
    const { userID, bodyID, noteText } = req.body;
    const result = await (await pool).request()
      .input("userID", userID)
      .input("bodyID", bodyID)
      .input("noteText", noteText)
      .query(`
        INSERT INTO UserNotes (UserID, BodyID, NoteText)
        VALUES (@userID, @bodyID, @noteText);
        SELECT SCOPE_IDENTITY() AS NoteID;
      `);
    res.status(201).json({ success: true, noteID: result.recordset[0].NoteID });
  } catch (error) {
    console.error("CREATE note error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// READ all notes
router.get("/", async (req, res) => {
  try {
    const result = await (await pool).request().query("SELECT * FROM UserNotes");
    res.json({ success: true, data: result.recordset });
  } catch (error) {
    console.error("READ notes error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// READ a single note by NoteID
router.get("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const result = await (await pool).request()
      .input("id", id)
      .query("SELECT * FROM UserNotes WHERE NoteID = @id");
    if (result.recordset.length === 0) {
      return res.status(404).json({ success: false, message: "Note not found" });
    }
    res.json({ success: true, data: result.recordset[0] });
  } catch (error) {
    console.error("READ note error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// UPDATE a note by NoteID
router.put("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const { noteText } = req.body;
    await (await pool).request()
      .input("id", id)
      .input("noteText", noteText)
      .query("UPDATE UserNotes SET NoteText = @noteText, UpdatedAt = GETDATE() WHERE NoteID = @id");
    res.json({ success: true, message: "Note updated successfully" });
  } catch (error) {
    console.error("UPDATE note error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// DELETE a note by NoteID
router.delete("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    await (await pool).request()
      .input("id", id)
      .query("DELETE FROM UserNotes WHERE NoteID = @id");
    res.json({ success: true, message: "Note deleted successfully" });
  } catch (error) {
    console.error("DELETE note error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
