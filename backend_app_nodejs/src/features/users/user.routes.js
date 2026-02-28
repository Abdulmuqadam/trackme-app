const router = require("express").Router();
const userController = require("./user.controller");
const { authenticateToken } = require("../../shared/middleware/auth.middleware");
const { authLimiter, signupLimiter } = require("../../shared/middleware/rateLimiter.middleware");
const { userSignupValidators, loginValidators } = require("./user.validators");

// Public routes (stricter rate limit for auth)
router.post("/signup", signupLimiter, userSignupValidators, userController.signUp);
router.post("/login", authLimiter, loginValidators, userController.login);
router.post("/verify", userController.checkUserIsValid);
router.get("/emailchecker", userController.checkUserEmail);

// Protected routes (require valid JWT)
router.post("/update/:id", authenticateToken, userController.updateUser);
router.post("/getuser", authenticateToken, userController.userById);

module.exports = router;
