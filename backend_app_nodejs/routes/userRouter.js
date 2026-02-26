const userController = require("../controllers/userController");
const router = require("express").Router();

router.post("/signup", userController.signUp);
router.post("/login", userController.login);
router.post("/update/:id", userController.updateUser);
router.post("/verify", userController.checkUserIsValid);
router.post("/getuser", userController.userById);
router.post("/emailchecker", userController.checkUserEmail);

module.exports = router;
