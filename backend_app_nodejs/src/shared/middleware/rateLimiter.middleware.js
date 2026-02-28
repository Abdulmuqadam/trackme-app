const rateLimit = require("express-rate-limit");

/** General API rate limiter: 100 requests per 15 minutes per IP */
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: "Too many requests, please try again later." },
});

/** Stricter limiter for auth endpoints: 5 attempts per 15 minutes per IP */
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: "Too many authentication attempts, please try again later." },
});

/** Signup limiter: 3 signups per hour per IP */
const signupLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,
  max: 3,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: "Too many signup attempts, please try again later." },
});

module.exports = { apiLimiter, authLimiter, signupLimiter };
