import express from 'express';
const router = express.Router();

// ⚠️ Make sure your db connection export matches this path
// Adjust if your project uses a different db file
import db from '../db.js';

// ================= CREATE ORDER =================
// This route saves ordered products into MySQL order_items table

router.post("/create-order", async (req, res) => {
  try {
    const { user_id, items, payment_method, address, total } = req.body;

    if (!user_id || !items || !items.length) {
      return res.status(400).json({ error: "Invalid order data" });
    }

    // Unique Order ID
    const order_id = "ORD_" + Date.now();

    // 🔥 Insert master order into orders table (UPDATED to match DB schema)
    await db.query(
      `INSERT INTO orders
       (order_id, firebase_uid, payment_method, total_amount, payment_status, order_status, address_id)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [
        order_id,
        user_id,
        payment_method || 'UNKNOWN',
        total || 0,
        'SUCCESS',      // payment_status
        'PLACED',       // order_status
        1               // temporary address_id (replace later with real address id)
      ]
    );

    // Insert each product into order_items table
    for (const item of items) {
      await db.query(
        `INSERT INTO order_items
        (order_id, product_id, product_name, price, quantity)
        VALUES (?, ?, ?, ?, ?)`,
        [
          order_id,
          item.product_id,
          item.product_name,
          item.price,
          item.quantity,
        ]
      );
    }

    return res.json({ success: true, order_id });
  } catch (error) {
    console.error("CREATE ORDER ERROR:", error);
    res.status(500).json({ error: "Order creation failed" });
  }
});

export default router;