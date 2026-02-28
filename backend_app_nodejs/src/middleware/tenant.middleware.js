const db = require("../../model");

const Organization = db.Organizations;

/**
 * Tenant resolution middleware.
 *
 * Resolves the active organization from one of two sources (checked in order):
 *  1. X-API-Key request header  (mobile app / API clients)
 *  2. X-Organization-Subdomain request header (web / admin dashboard)
 *
 * On success sets req.organization and req.organizationId then calls next().
 * Returns 401 if neither header is present.
 * Returns 404 if no matching organization is found.
 * Returns 403 if the organization's subscription is inactive/expired.
 */
const getTenant = async (req, res, next) => {
  try {
    const apiKey = req.headers["x-api-key"];
    const subdomain = req.headers["x-organization-subdomain"];

    if (!apiKey && !subdomain) {
      return res.status(401).json({
        error: "Organization context required. Provide X-API-Key or X-Organization-Subdomain header.",
      });
    }

    const where = apiKey ? { api_key: apiKey } : { subdomain };
    const organization = await Organization.findOne({ where });

    if (!organization) {
      return res.status(404).json({ error: "Organization not found." });
    }

    if (!organization.isActive()) {
      return res.status(403).json({
        error: "Organization subscription is inactive or expired.",
        subscription_status: organization.subscription_status,
      });
    }

    req.organization = organization;
    req.organizationId = organization.id;
    next();
  } catch (err) {
    next(err);
  }
};

module.exports = { getTenant };
