/**
 * Wraps an async route handler so any thrown error is forwarded
 * to Express's error-handling middleware instead of causing an
 * unhandled promise rejection.
 *
 * Usage:
 *   router.post("/route", asyncHandler(async (req, res) => { ... }));
 */
const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

module.exports = { asyncHandler };
