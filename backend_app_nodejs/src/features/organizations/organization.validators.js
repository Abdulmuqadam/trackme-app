const { body } = require("express-validator");
const { handleValidationErrors, emailValidator, passwordValidator, nameValidator } = require("../../shared/middleware/validators");

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

module.exports = { organizationSignupValidators };
