const facilitatorController = require("../controllers/facilitatorController");
const router = require("express").Router();

router.post("/signup", facilitatorController.signUp);
router.post("/login", facilitatorController.login);
router.post("/update/:id", facilitatorController.updateFascilitator);
router.post("/verify", facilitatorController.checkFacilitatorIsValid);
router.post("/getfacilitator", facilitatorController.facilitatorById);
router.post("/emailchecker", facilitatorController.checkFacilitatorEmail);

module.exports = router;
