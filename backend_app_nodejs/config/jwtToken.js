const jwt = require("jsonwebtoken");
require("dotenv").config();

const generateJwtToken = (role, id, organizationId = null) => {
  const secretKey = "" + process.env.JWT_SECRET;
  const expiresIn = "12d";

  const payload = { role, id };
  if (organizationId) payload.organizationId = organizationId;

  const token = jwt.sign(payload, secretKey, { expiresIn }); // Pass expiresIn as an option
  return token;
};

function validateAndExtractInfo(token, secretKey) {
  return new Promise((resolve, reject) => {
    jwt.verify(token, secretKey, (err, decodedToken) => {
      if (err) {
        // Token is invalid or expired
        reject(err);
      } else {
        // Token is valid, extract roles and user ID if available
        const roles = decodedToken.role || []; // Change decodedToken.roles to decodedToken.role
        const userId = decodedToken.id || null; // Change decodedToken.userId to decodedToken.id
        const organizationId = decodedToken.organizationId || null;
        resolve({ roles, userId, organizationId });
      }
    });
  });
}

module.exports = {
  generateJwtToken,
  validateAndExtractInfo,
};
