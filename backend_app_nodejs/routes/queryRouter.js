const queryController = require("../controllers/queryController");
const { authenticateToken } = require("../src/middleware/auth.middleware");
const router = require("express").Router();

// All query routes require authentication
router.post("/save", authenticateToken, queryController.saveQuery);
router.post("/updatelocation", authenticateToken, queryController.postLocation);
router.post("/getquerybyfacilitatorid", authenticateToken, queryController.getQueryByFacilitatorid);
router.post("/getquerybyusername", authenticateToken, queryController.getQueryByUserName);
router.post("/updatequerycomplete", authenticateToken, queryController.updateCompletion);

module.exports = router;
