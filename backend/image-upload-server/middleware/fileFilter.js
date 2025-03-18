const path = require('path'); // Add this line to import the path module
const { ALLOWED_TYPES } = require('../config/config');

const fileFilter = (_req, file, cb) => {
  const ext = path.extname(file.originalname).toLowerCase();
  const mimeType = file.mimetype;
  if (ALLOWED_TYPES[mimeType]?.includes(ext)) {
    return cb(null, true);
  }
  cb(new Error('Only JPEG, PNG, and GIF images are allowed'), false);
};

module.exports = fileFilter;