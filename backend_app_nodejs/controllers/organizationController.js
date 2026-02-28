const { genSaltSync, hashSync } = require("bcryptjs");
const jwt = require("../config/jwtToken");
const db = require("../model");

const Organization = db.Organizations;
const User = db.Users;

/**
 * POST /api/organizations/signup
 * Creates a new organization + admin user in a single transaction.
 */
const signupOrganization = async (req, res) => {
  const {
    organization_name,
    subdomain,
    admin_email,
    admin_password,
    admin_first_name,
    admin_last_name,
  } = req.body;

  const transaction = await db.sequelize.transaction();
  try {
    // Ensure subdomain is not already taken
    const existing = await Organization.findOne({ where: { subdomain }, transaction });
    if (existing) {
      await transaction.rollback();
      return res.status(409).json({ error: "Subdomain is already taken." });
    }

    // Generate API key
    const apiKey = Organization.generateApiKey();

    // Set trial window from env or default 14 days
    const trialDays = parseInt(process.env.TRIAL_PERIOD_DAYS || "14", 10);
    const trialEndsAt = new Date();
    trialEndsAt.setDate(trialEndsAt.getDate() + trialDays);

    // Create organization
    const organization = await Organization.create(
      {
        name: organization_name,
        subdomain,
        api_key: apiKey,
        trial_ends_at: trialEndsAt,
        subscription_status: "trial",
        subscription_tier: "free",
      },
      { transaction }
    );

    // Hash admin password
    const hashedPassword = hashSync(admin_password, genSaltSync(10));

    // Create admin user
    const adminUser = await User.create(
      {
        firstname: admin_first_name,
        lastname: admin_last_name,
        email: admin_email,
        password: hashedPassword,
        organization_id: organization.id,
        gender: "Other",
      },
      { transaction }
    );

    await transaction.commit();

    // Issue JWT containing organization context
    const token = jwt.generateJwtToken("admin", adminUser.id, organization.id);

    const dashboardBaseUrl =
      process.env.DASHBOARD_BASE_URL || "https://{subdomain}.trackme.app/dashboard";

    res.status(201).json({
      organization: {
        id: organization.id,
        name: organization.name,
        subdomain: organization.subdomain,
        api_key: apiKey,
        trial_ends_at: organization.trial_ends_at,
        dashboard_url: dashboardBaseUrl.replace("{subdomain}", subdomain),
      },
      admin_token: token,
    });
  } catch (error) {
    await transaction.rollback();
    console.error("Organization signup error:", error);
    res.status(500).json({ error: "Failed to create organization." });
  }
};

/**
 * GET /api/organizations/me
 * Returns the authenticated organization's details (requires tenant middleware).
 */
const getOrganization = async (req, res) => {
  try {
    const org = req.organization;
    res.json({
      id: org.id,
      name: org.name,
      subdomain: org.subdomain,
      subscription_tier: org.subscription_tier,
      subscription_status: org.subscription_status,
      max_users: org.max_users,
      max_facilitators: org.max_facilitators,
      trial_ends_at: org.trial_ends_at,
      subscription_ends_at: org.subscription_ends_at,
    });
  } catch (error) {
    res.status(500).json({ error: "Failed to retrieve organization." });
  }
};

module.exports = { signupOrganization, getOrganization };
