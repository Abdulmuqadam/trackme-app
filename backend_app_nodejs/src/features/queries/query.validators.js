const { body } = require("express-validator");
const { handleValidationErrors } = require("../../shared/middleware/validators");

const queryTypeValidator = body("querytype")
  .isIn(["Home Invasion", "Medical Help", "Fire Extinguisher", "Travel Emergency"])
  .withMessage("Invalid query type");

const locationValidator = body("location")
  .matches(/^-?\d+(\.\d+)?,-?\d+(\.\d+)?$/)
  .withMessage("Location must be in lat,lng format");

const saveQueryValidators = [
  body("text").trim().notEmpty().withMessage("Query text is required"),
  queryTypeValidator,
  locationValidator,
  body("postedBy").notEmpty().withMessage("postedBy is required"),
  handleValidationErrors,
];

module.exports = { saveQueryValidators };
