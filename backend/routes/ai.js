import express from "express";
import db from "../db.js";

const router = express.Router();

// --------------------------------------
// 🧠 AI Confusion Event Route
// --------------------------------------
router.post("/confusion-event", async (req, res) => {
  try {
    const { user_id, screen, reason } = req.body;

    console.log("AI CONFUSION:", user_id, screen, reason);

    await db.query(
      `INSERT INTO confusion_events (user_id, screen_name, reason)
       VALUES (?, ?, ?)`,
      [user_id, screen, reason]
    );

    res.json({ success: true });
  } catch (err) {
    console.error("Confusion insert failed:", err);
    res.status(500).json({ error: "server error" });
  }
});

// --------------------------------------------------
// 🔮 Predictive AI Route
// --------------------------------------------------
router.post('/predict', async (req, res) => {
  try {
    const { user_id, predicted_screen, based_on_screen } = req.body;

    if (!user_id || !predicted_screen) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    await db.query(
      `INSERT INTO ai_predictions (user_id, predicted_screen, based_on_screen)
       VALUES (?, ?, ?)`,
      [user_id, predicted_screen, based_on_screen]
    );

    console.log(
      'AI PREDICTION:',
      user_id,
      predicted_screen,
      based_on_screen
    );

    res.status(200).json({ message: 'Prediction saved' });
  } catch (err) {
    console.error('Prediction insert failed:', err);
    res.status(500).json({ error: 'Database error' });
  }
});

export default router;