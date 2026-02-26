const jsonWebToken = require("jsonwebtoken");
require("dotenv").config();

/**
 * Middleware to verify JWT from Authorization header (Bearer token).
 * Attaches decoded token payload to req.user on success.
 */
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1]; // Bearer <token>

  if (!token) {
    return res.status(401).json({ error: "Access denied. No token provided." });
  }

  jsonWebToken.verify(token, process.env.JWT_SECRET, (err, decoded) => {
    if (err) {
      return res.status(401).json({ error: "Invalid or expired token." });
    }
    req.user = decoded;
    next();
  });
};

module.exports = { authenticateToken };
