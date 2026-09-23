function errorHandler(err, req, res, next) {
  console.error('[API Error Log]', err.stack || err.message || err);
  const statusCode = err.statusCode || 500;
  return res.status(statusCode).json({
    success: false,
    error: err.message || 'Internal Server Error',
    timestamp: new Date().toISOString()
  });
}

module.exports = errorHandler;
