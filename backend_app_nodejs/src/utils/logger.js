const morgan = require("morgan");

/**
 * HTTP request logger.
 * Uses the "dev" format in development and "combined" (Apache-style) in production.
 */
const requestLogger = morgan(
  process.env.NODE_ENV === "production" ? "combined" : "dev"
);

module.exports = { requestLogger };
