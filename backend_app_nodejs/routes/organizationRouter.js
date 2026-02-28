const organizationController = require("../controllers/organizationController");
const { getTenant } = require("../src/middleware/tenant.middleware");
const { organizationSignupValidators } = require("../src/middleware/validators");
const { signupLimiter } = require("../src/middleware/rateLimiter.middleware");
const router = require("express").Router();

// Public: create a new organization + admin account
router.post("/signup", signupLimiter, organizationSignupValidators, organizationController.signupOrganization);

// Protected: current organization info (requires valid tenant headers)
router.get("/me", getTenant, organizationController.getOrganization);

module.exports = router;
