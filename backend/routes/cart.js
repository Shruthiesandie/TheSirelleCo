import express from "express";
import db from "../db.js";

const router = express.Router();

// ➕ ADD TO CART
router.post("/add", async (req, res) => {
  try {
    const { uid, ui_id } = req.body;

    if (!uid || !ui_id) {
      return res.status(400).json({ message: "Missing data" });
    }

    await db.query(
      `
      INSERT INTO cart (firebase_uid, ui_id, quantity)
      VALUES (?, ?, 1)
      ON DUPLICATE KEY UPDATE quantity = quantity + 1
      `,
      [uid, ui_id]
    );

    res.sendStatus(200);
  } catch (err) {
    console.error("ADD TO CART ERROR:", err);
    res.sendStatus(500);
  }
});

// ➖ REMOVE FROM CART
router.post("/remove", async (req, res) => {
  try {
    const { uid, ui_id } = req.body;

    if (!uid || !ui_id) {
      return res.status(400).json({ message: "Missing data" });
    }

    await db.query(
      "DELETE FROM cart WHERE firebase_uid=? AND ui_id=?",
      [uid, ui_id]
    );

    res.sendStatus(200);
  } catch (err) {
    console.error("REMOVE FROM CART ERROR:", err);
    res.sendStatus(500);
  }
});

// 🔄 GET CART ITEMS
router.get("/:uid", async (req, res) => {
  try {
    const [rows] = await db.query(
      `
      SELECT
        p.product_id,
        p.ui_id,
        p.name,
        p.price,
        p.image_url,
        p.category,
        c.quantity
      FROM cart c
      JOIN products p ON c.ui_id = p.ui_id
      WHERE c.firebase_uid = ?
      `,
      [req.params.uid]
    );

    res.json(rows);
  } catch (err) {
    console.error("GET CART ERROR:", err);
    res.sendStatus(500);
  }
});

// 🗑 CLEAR CART
router.delete("/:uid", async (req, res) => {
  try {
    await db.query(
      "DELETE FROM cart WHERE firebase_uid=?",
      [req.params.uid]
    );

    res.sendStatus(200);
  } catch (err) {
    console.error("CLEAR CART ERROR:", err);
    res.sendStatus(500);
  }
});

export default router;