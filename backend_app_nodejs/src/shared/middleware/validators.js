const { body, validationResult } = require("express-validator");

/**
 * Shared validation primitives.
 * Feature-specific validator arrays live in their own feature directory.
 * Import this module for the shared field validators and error handler.
 */

/** Middleware to collect validation errors and return 422 if any. */
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(422).json({ errors: errors.array() });
  }
  next();
};

// ── Reusable field validators ─────────────────────────────────────────────────

const emailValidator = body("email")
  .isEmail()
  .withMessage("Valid email is required")
  .normalizeEmail();

const passwordValidator = body("password")
  .isLength({ min: 8 })
  .withMessage("Password must be at least 8 characters")
  .matches(/[A-Z]/)
  .withMessage("Password must contain at least one uppercase letter")
  .matches(/[0-9]/)
  .withMessage("Password must contain at least one number");

const nameValidator = (field) =>
  body(field)
    .trim()
    .notEmpty()
    .withMessage(`${field} is required`)
    .isLength({ max: 50 })
    .withMessage(`${field} must be at most 50 characters`)
    .not()
    .matches(/['";]/)
    .withMessage(`${field} contains invalid characters`);

module.exports = {
  handleValidationErrors,
  emailValidator,
  passwordValidator,
  nameValidator,
};
