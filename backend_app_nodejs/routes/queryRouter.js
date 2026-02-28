const queryController = require("../controllers/queryController");
const { authenticateToken } = require("../src/middleware/auth.middleware");
const { saveQueryValidators } = require("../src/middleware/validators");
const router = require("express").Router();

// All query routes require authentication
// save: multer parses multipart, then validators run, then controller
router.post(
  "/save",
  authenticateToken,
  queryController.uploadMiddleware,
  saveQueryValidators,
  queryController.saveQuery
);
router.post("/updatelocation", authenticateToken, queryController.postLocation);
router.post("/getquerybyfacilitatorid", authenticateToken, queryController.getQueryByFacilitatorid);
router.post("/getquerybyusername", authenticateToken, queryController.getQueryByUserName);
router.post("/updatequerycomplete", authenticateToken, queryController.updateCompletion);

// Returns a 1-hour pre-signed S3 URL for the audio attachment
router.get("/:id/audio-url", authenticateToken, queryController.getAudioUrl);

module.exports = router;
