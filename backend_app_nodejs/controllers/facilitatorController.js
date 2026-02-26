const { genSaltSync, hashSync, compareSync } = require("bcryptjs");
const jwt = require("../config/jwtToken");
const db = require("../model");
const jsonWebToken = require("jsonwebtoken");
require("dotenv").config({ path: "./.env" });

// Create main model
const Facilitator = db.facilitators;

// signup
const signUp = async (req, res) => {
  try {
    if (!req.body.password) {
      return res.status(400).json({ message: "Password is required" });
    }

    const salt = genSaltSync(10);
    const hashPassword = hashSync(req.body.password, salt);
    const image = req.body.profilepic;
    const imageData = Buffer.from(image, "base64");

    const data = {
      firstname: req.body.firstname,
      lastname: req.body.lastname,
      gender: req.body.gender,
      email: req.body.email,
      password: hashPassword,
      number: req.body.number,
      role: req.body.role,
      profilepic: imageData,
    };

    const signup = await Facilitator.create(data);
    const role = data.role;
    const token = jwt.generateJwtToken(role, signup.id);
    res.status(200).json({
      message: "Facilitator created successfully.",
      token,
      userId: signup.id,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Internal server error" });
  }
};

// login
const login = async (req, res) => {
  try {
    const { email, password } = req.body;
    const facilitator = await Facilitator.findOne({ where: { email } });
    if (!facilitator) {
      return res.status(404).json({ message: "facilitator not found" });
    }
    const isPasswordValid = compareSync(password, facilitator.password);
    if (!isPasswordValid) {
      return res.status(401).json({ message: "Invalid Password" });
    }
    const role = facilitator.role;
    const token = jwt.generateJwtToken(role, facilitator.id);
    res.status(200).json({ token, role: role, userId: facilitator.id });
  } catch (error) {
    res.status(500).json({ message: "Internal server error" });
  }
};

// Update Facilitator
const updateFascilitator = async (req, res) => {
  try {
    const userId = req.params.id;
    const { firstname, lastname, gender, number, profilepic } = req.body;

    const user = await Facilitator.findByPk(userId);

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    user.firstname = firstname || user.firstname;
    user.lastname = lastname || user.lastname;
    user.gender = gender || user.gender;
    user.number = number || user.number;

    if (profilepic) {
      const imageData = Buffer.from(profilepic, "base64");
      user.profilepic = imageData;
    }

    await user.save();

    res.status(200).json({ message: "User updated successfully", user });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Internal server error" });
  }
};

// Facilitator Info By Id

const facilitatorById = async (req, res) => {
  try {
    const id = parseInt(req.body.userId);
    const facilitator = await Facilitator.findByPk(id);
    if (!facilitator) {
      return res.status(404).json({ message: "facilitator Not Found!" });
    }
    res.status(200).json(facilitator);
  } catch (error) {
    res.status(500).json({ message: "Server Error" });
  }
};

// Check Facilitator is Valid
const checkFacilitatorIsValid = (req, res) => {
  const token = req.body.token;

  if (!token) {
    return res.status(401).send({ error: "no token is provided" });
  }

  jsonWebToken.verify(token, process.env.JWT_SECRET, (err, decodedToken) => {
    if (err) {
      return res.status(401).send({ error: "Invalid token" });
    } else {
      const roles = decodedToken.role || [];
      const userId = decodedToken.id || null;
      return res
        .status(200)
        .json({ message: "Token is valid", roles: roles, userId: userId });
    }
  });
};
// email checker for Facilitator
const checkFacilitatorEmail = async (req, res) => {
  try {
    const emailToCheck = req.query.email;
    if (!emailToCheck) {
      return res.status(400).json({ error: "Email Parameter is required" });
    }
    const facilitator = await Facilitator.findOne({
      where: { email: emailToCheck },
    });
    const emailExists = !!facilitator; // Convert to boolean
    res.status(200).json({ emailExists });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Internal server error", error: error });
  }
};

module.exports = {
  signUp,
  login,
  checkFacilitatorIsValid,
  facilitatorById,
  updateFascilitator,
  checkFacilitatorEmail,
};
