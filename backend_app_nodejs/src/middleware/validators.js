// Re-exports shared validators base + all feature-specific validator sets.
const base = require("../shared/middleware/validators");
const { userSignupValidators, loginValidators: userLoginValidators } = require("../features/users/user.validators");
const { facilitatorSignupValidators, loginValidators: facLoginValidators } = require("../features/facilitators/facilitator.validators");
const { saveQueryValidators } = require("../features/queries/query.validators");
const { organizationSignupValidators } = require("../features/organizations/organization.validators");

module.exports = {
  ...base,
  userSignupValidators,
  loginValidators: userLoginValidators,
  facilitatorSignupValidators,
  saveQueryValidators,
  organizationSignupValidators,
};
