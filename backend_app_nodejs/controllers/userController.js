const { genSaltSync, hashSync, compareSync } = require("bcryptjs");
const jwt = require("../config/jwtToken");
const db = require("../model");
const jsonWebToken = require("jsonwebtoken");
require("dotenv").config({ path: "./.env" });

// Create main model
const User = db.Users;

// Signup
const signUp = async (req, res) => {
  try {
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
      profilepic: imageData,
    };

    const signup = await User.create(data);
    const role = "user";
    const token = jwt.generateJwtToken(role, signup.id);
    res
      .status(200)
      .json({ message: "User created successfully", token, userId: signup.id });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Internal server error", error });
  }
};

// login
const login = async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ where: { email } });
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
    const isPasswordValid = compareSync(password, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({ message: "Invalid Password" });
    }
    const role = "user";
    const token = jwt.generateJwtToken(role, user.id);
    res.status(200).json({ token, userId: user.id });
  } catch (error) {
    res.status(500).json({ message: "Internal server error", error });
  }
};

// User Info By Id
const userById = async (req, res) => {
  try {
    const id = parseInt(req.body.userId);
    const user = await User.findByPk(id);
    if (!user) {
      return res.status(404).json({ message: "User Not Found!" });
    }
    res.status(200).json(user);
  } catch (error) {
    res.status(500).json({ message: "Server Error" });
  }
};

// Update user
const updateUser = async (req, res) => {
  try {
    const userId = req.params.id; // Assuming you're passing user ID in the URL
    const { firstname, lastname, gender, number, profilepic } = req.body;

    const user = await User.findByPk(userId);

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

const checkUserIsValid = (req, res) => {
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

// email checker for user
const checkUserEmail = async (req, res) => {
  try {
    const emailToCheck = req.query.email;
    if (!emailToCheck) {
      return res.status(400).json({ error: "Email Parameter is required" });
    }
    const user = await User.findOne({ where: { email: emailToCheck } });
    const emailExists = !!user; // Convert to boolean
    res.status(200).json({ emailExists });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Internal server error", error: error });
  }
};

module.exports = {
  signUp,
  login,
  updateUser,
  checkUserIsValid,
  userById,
  checkUserEmail,
};
