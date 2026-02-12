

import express from 'express';
import pool from '../db.js';

const router = express.Router();

/**
 * GET /search?q=keyword
 * Searches products by name, category, or description
 */
router.get('/', async (req, res) => {
  try {
    const { q } = req.query;

    // If no query provided, return empty list
    if (!q || q.trim() === '') {
      return res.status(200).json([]);
    }

    const searchTerm = `%${q}%`;

    const [rows] = await pool.query(
      `
      SELECT 
        product_id,
        ui_id,
        name,
        price,
        image_url,
        category
      FROM products
      WHERE
        name LIKE ?
        OR category LIKE ?
        OR description LIKE ?
      ORDER BY name ASC
      `,
      [searchTerm, searchTerm, searchTerm]
    );

    res.status(200).json(rows);
  } catch (error) {
    console.error('Search error:', error);
    res.status(500).json({ message: 'Search failed' });
  }
});

export default router;