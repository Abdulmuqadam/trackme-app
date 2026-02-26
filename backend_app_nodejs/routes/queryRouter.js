const queryController = require("../controllers/queryController");
const router = require("express").Router();

router.post("/save", queryController.saveQuery);
router.post("/updatelocation", queryController.postLocation);
router.post(
  "/getquerybyfacilitatorid",
  queryController.getQueryByFacilitatorid
);
router.post("/getquerybyusername", queryController.getQueryByUserName);
router.post("/updatequerycomplete", queryController.updateCompletion);

module.exports = router;
