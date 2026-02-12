

import express from 'express';
import pool from '../db.js';

const router = express.Router();

// GET all addresses for a user
router.get('/:firebase_uid', async (req, res) => {
  try {
    const { firebase_uid } = req.params;

    const [rows] = await pool.query(
      `SELECT *
       FROM addresses
       WHERE firebase_uid = ?
       ORDER BY is_default DESC, created_at DESC`,
      [firebase_uid]
    );

    res.json(rows);
  } catch (err) {
    console.error('GET addresses error:', err);
    res.status(500).json({ message: 'Database error' });
  }
});

// ADD a new address
router.post('/', async (req, res) => {
  try {
    const {
      firebase_uid,
      full_name,
      phone,
      address_line,
      city,
      state,
      pincode,
      label,
      is_default
    } = req.body;

    if (is_default) {
      await pool.query(
        'UPDATE addresses SET is_default = FALSE WHERE firebase_uid = ?',
        [firebase_uid]
      );
    }

    await pool.query(
      `INSERT INTO addresses
       (firebase_uid, full_name, phone, address_line, city, state, pincode, label, is_default)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        firebase_uid,
        full_name,
        phone,
        address_line,
        city,
        state,
        pincode,
        label || 'HOME',
        is_default || false
      ]
    );

    res.json({ success: true });
  } catch (err) {
    console.error('ADD address error:', err);
    res.status(500).json({ message: 'Database error' });
  }
});

// SET default address
router.put('/default/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { firebase_uid } = req.body;

    await pool.query(
      'UPDATE addresses SET is_default = FALSE WHERE firebase_uid = ?',
      [firebase_uid]
    );

    await pool.query(
      'UPDATE addresses SET is_default = TRUE WHERE id = ?',
      [id]
    );

    res.json({ success: true });
  } catch (err) {
    console.error('SET default address error:', err);
    res.status(500).json({ message: 'Database error' });
  }
});

// DELETE address
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    await pool.query('DELETE FROM addresses WHERE id = ?', [id]);

    res.json({ success: true });
  } catch (err) {
    console.error('DELETE address error:', err);
    res.status(500).json({ message: 'Database error' });
  }
});

export default router;