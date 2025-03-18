const express = require('express');
const helmet = require('helmet');
const path = require('path');
const cors = require('cors'); // Add this

const app = express();
const { PORT, UPLOAD_DIR } = require('./config/config');
const uploadRoutes = require('./routes/uploadRoutes');
const cityRoutes = require('./routes/cityRoutes');

// Middleware
app.use(helmet());
app.use(cors()); // Add this
app.use(express.json({ limit: '1mb' }));
app.use('/uploads', express.static(UPLOAD_DIR, {
  maxAge: '1d',
  etag: true
}));

// API Routes
app.use('/api', uploadRoutes);
app.use('/api/cities', cityRoutes);

// Error handling middleware
app.use((err, _req, res, next) => {
  if (err instanceof multer.MulterError) {
    const messages = {
      'LIMIT_FILE_SIZE': `File too large (max ${MAX_FILE_SIZE / 1024 / 1024}MB)`,
      'LIMIT_UNEXPECTED_FILE': 'Invalid file field'
    };
    return res.status(400).json({
      error: messages[err.code] || 'Upload error'
    });
  }
  res.status(500).json({ error: 'Internal server error' });
});

// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error);
  process.exit(1);
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});