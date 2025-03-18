const express = require('express');
const router = express.Router();
const { CITIES } = require('../config/config');

router.get('/', (req, res) => {
  try {
    const formattedCities = Object.entries(CITIES).reduce((acc, [country, cities]) => {
      acc[country] = cities.map(city => `${city.name} - ${city.code}`);
      return acc;
    }, {});
    res.json({
      success: true,
      data: formattedCities
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch cities' });
  }
});

router.get('/search', (req, res) => {
  try {
    const { q, country } = req.query;
    if (!q || typeof q !== 'string') {
      return res.status(400).json({ error: 'Query parameter "q" is required' });
    }

    const searchTerm = q.toLowerCase().trim();
    const results = [];

    if (CITIES[country]) {
      const matches = CITIES[country]
        .filter(city => city.name.toLowerCase().includes(searchTerm))
        .map(city => city.name);

      res.json({
        success: true,
        data: matches
      });
    } else {
      res.status(400).json({ error: 'Invalid country' });
    }
  } catch (error) {
    res.status(500).json({ error: 'Failed to search cities' });
  }
});

module.exports = router;