const Sentry = require("@sentry/node");

/**
 * Centralized error-handling middleware.
 * Must be registered LAST with app.use() after all routes.
 */
// eslint-disable-next-line no-unused-vars -- Express requires the 4-argument signature for error middleware
const errorHandler = (err, req, res, next) => {
  const statusCode = err.statusCode || 500;
  const message = err.message || "Internal Server Error";

  // Report unexpected server errors to Sentry
  if (statusCode >= 500 && process.env.SENTRY_DSN) {
    Sentry.captureException(err);
  }

  if (process.env.NODE_ENV !== "production") {
    console.error(`[${req.method}] ${req.path} — ${statusCode}: ${message}`);
    if (err.stack) console.error(err.stack);
  }

  res.status(statusCode).json({
    success: false,
    message,
    ...(process.env.NODE_ENV !== "production" && { stack: err.stack }),
  });
};

module.exports = { errorHandler };
