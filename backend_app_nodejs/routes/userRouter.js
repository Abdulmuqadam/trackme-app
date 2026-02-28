const userController = require("../controllers/userController");
const { authenticateToken } = require("../src/middleware/auth.middleware");
const { authLimiter, signupLimiter } = require("../src/middleware/rateLimiter.middleware");
const { userSignupValidators, loginValidators } = require("../src/middleware/validators");
const router = require("express").Router();

// Public routes (stricter rate limit for auth)
router.post("/signup", signupLimiter, userSignupValidators, userController.signUp);
router.post("/login", authLimiter, loginValidators, userController.login);
router.post("/verify", userController.checkUserIsValid);
router.get("/emailchecker", userController.checkUserEmail);

// Protected routes (require valid JWT)
router.post("/update/:id", authenticateToken, userController.updateUser);
router.post("/getuser", authenticateToken, userController.userById);

module.exports = router;
