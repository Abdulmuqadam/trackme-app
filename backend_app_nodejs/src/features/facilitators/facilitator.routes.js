const router = require("express").Router();
const facilitatorController = require("./facilitator.controller");
const { authenticateToken } = require("../../shared/middleware/auth.middleware");
const { authLimiter, signupLimiter } = require("../../shared/middleware/rateLimiter.middleware");
const { facilitatorSignupValidators, loginValidators } = require("./facilitator.validators");

// Public routes
router.post("/signup", signupLimiter, facilitatorSignupValidators, facilitatorController.signUp);
router.post("/login", authLimiter, loginValidators, facilitatorController.login);
router.post("/verify", facilitatorController.checkFacilitatorIsValid);
router.get("/emailchecker", facilitatorController.checkFacilitatorEmail);

// Protected routes
router.post("/update/:id", authenticateToken, facilitatorController.updateFacilitator);
router.post("/getfacilitator", authenticateToken, facilitatorController.facilitatorById);

module.exports = router;
