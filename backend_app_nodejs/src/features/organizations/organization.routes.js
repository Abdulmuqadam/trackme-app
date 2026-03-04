const router = require("express").Router();
const organizationController = require("./organization.controller");
const { getTenant } = require("../../shared/middleware/tenant.middleware");
const { organizationSignupValidators } = require("./organization.validators");
const { signupLimiter } = require("../../shared/middleware/rateLimiter.middleware");

// Public: create a new organization + admin account
router.post("/signup", signupLimiter, organizationSignupValidators, organizationController.signupOrganization);

// Protected: current organization info (requires valid tenant headers)
router.get("/me", getTenant, organizationController.getOrganization);

module.exports = router;
