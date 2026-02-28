const facilitatorController = require("../controllers/facilitatorController");
const { authenticateToken } = require("../src/middleware/auth.middleware");
const { authLimiter, signupLimiter } = require("../src/middleware/rateLimiter.middleware");
const { facilitatorSignupValidators, loginValidators } = require("../src/middleware/validators");
const router = require("express").Router();

// Public routes
router.post("/signup", signupLimiter, facilitatorSignupValidators, facilitatorController.signUp);
router.post("/login", authLimiter, loginValidators, facilitatorController.login);
router.post("/verify", facilitatorController.checkFacilitatorIsValid);
router.get("/emailchecker", facilitatorController.checkFacilitatorEmail);

// Protected routes
router.post("/update/:id", authenticateToken, facilitatorController.updateFacilitator);
router.post("/getfacilitator", authenticateToken, facilitatorController.facilitatorById);

module.exports = router;
