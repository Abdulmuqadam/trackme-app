const { body } = require("express-validator");
const { handleValidationErrors, emailValidator, passwordValidator, nameValidator } = require("../../shared/middleware/validators");

const facilitatorSignupValidators = [
  emailValidator,
  passwordValidator,
  nameValidator("firstname"),
  nameValidator("lastname"),
  body("gender")
    .isIn(["Male", "Female", "Other"])
    .withMessage("Gender must be Male, Female, or Other"),
  body("role")
    .isIn(["Police", "Ambulance", "Road Assistance", "Rescue"])
    .withMessage("Invalid facilitator role"),
  handleValidationErrors,
];

const loginValidators = [
  emailValidator,
  body("password").notEmpty().withMessage("Password is required"),
  handleValidationErrors,
];

module.exports = { facilitatorSignupValidators, loginValidators };
