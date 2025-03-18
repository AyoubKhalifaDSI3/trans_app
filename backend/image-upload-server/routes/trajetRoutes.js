const express = require('express');
const router = express.Router();
const { TRAJETS } = require('../config/config');

router.post('/add', (req, res) => {
  const { pickup, delivery } = req.body;

  if (!pickup || !delivery) {
    return res.status(400).json({ error: "Both pickup and delivery points are required" });
  }

  const newTrajet = { pickup, delivery };
  TRAJETS.push(newTrajet);

  res.json({ success: true, message: "Trajet ajouté avec succès", data: newTrajet });
});

module.exports = router;
