const { body, validationResult } = require("express-validator");

/** Middleware to collect validation errors and return 422 if any. */
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(422).json({ errors: errors.array() });
  }
  next();
};

// ── Field validators ─────────────────────────────────────────────────────────

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

const queryTypeValidator = body("querytype")
  .isIn(["Home Invasion", "Medical Help", "Fire Extinguisher", "Travel Emergency"])
  .withMessage("Invalid query type");

const locationValidator = body("location")
  .matches(/^-?\d+(\.\d+)?,-?\d+(\.\d+)?$/)
  .withMessage("Location must be in lat,lng format");

const userIdValidator = body("postedBy")
  .notEmpty()
  .withMessage("postedBy is required");

// ── Composed rule sets ────────────────────────────────────────────────────────

const userSignupValidators = [
  emailValidator,
  passwordValidator,
  nameValidator("firstname"),
  nameValidator("lastname"),
  body("gender")
    .isIn(["Male", "Female", "Other"])
    .withMessage("Gender must be Male, Female, or Other"),
  handleValidationErrors,
];

const loginValidators = [
  emailValidator,
  body("password").notEmpty().withMessage("Password is required"),
  handleValidationErrors,
];

const facilitatorSignupValidators = [
  emailValidator,
  passwordValidator,
  nameValidator("firstname"),
  nameValidator("lastname"),
  body("gender")
    .isIn(["Male", "Female", "Other"])
    .withMessage("Gender must be Male, Female, or Other"),
  body("role")
    .isIn(["Police", "Ambulance", "Road Assistance", "Rescue"])
    .withMessage("Invalid facilitator role"),
  handleValidationErrors,
];

const saveQueryValidators = [
  body("text").trim().notEmpty().withMessage("Query text is required"),
  queryTypeValidator,
  locationValidator,
  userIdValidator,
  handleValidationErrors,
];

const organizationSignupValidators = [
  body("organization_name").trim().notEmpty().withMessage("Organization name is required"),
  body("subdomain")
    .trim()
    .notEmpty()
    .withMessage("Subdomain is required")
    .matches(/^[a-z0-9-]+$/)
    .withMessage("Subdomain may only contain lowercase letters, numbers, and hyphens"),
  emailValidator.withMessage("Valid admin email is required"),
  passwordValidator,
  nameValidator("admin_first_name"),
  nameValidator("admin_last_name"),
  handleValidationErrors,
];

module.exports = {
  userSignupValidators,
  loginValidators,
  facilitatorSignupValidators,
  saveQueryValidators,
  organizationSignupValidators,
};
