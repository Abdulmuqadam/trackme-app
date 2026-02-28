const { randomBytes } = require("crypto");

module.exports = (sequelize, DataTypes) => {
  const Organization = sequelize.define(
    "organization",
    {
      id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
      },
      name: {
        type: DataTypes.STRING(255),
        allowNull: false,
      },
      subdomain: {
        type: DataTypes.STRING(50),
        allowNull: true,
        unique: true,
      },
      subscription_tier: {
        type: DataTypes.ENUM("free", "professional", "enterprise"),
        defaultValue: "free",
      },
      subscription_status: {
        type: DataTypes.ENUM("active", "trial", "suspended"),
        defaultValue: "trial",
      },
      max_users: {
        type: DataTypes.INTEGER,
        defaultValue: 10,
      },
      max_facilitators: {
        type: DataTypes.INTEGER,
        defaultValue: 5,
      },
      api_key: {
        type: DataTypes.STRING(64),
        allowNull: true,
        unique: true,
      },
      stripe_customer_id: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      trial_ends_at: {
        type: DataTypes.DATE,
        allowNull: true,
      },
      subscription_ends_at: {
        type: DataTypes.DATE,
        allowNull: true,
      },
    },
    {
      indexes: [
        { fields: ["subdomain"] },
        { fields: ["api_key"] },
      ],
    }
  );

  /** Returns true when the organization can accept API requests. */
  Organization.prototype.isActive = function () {
    return (
      this.subscription_status === "active" ||
      (this.subscription_status === "trial" &&
        this.trial_ends_at &&
        new Date(this.trial_ends_at) > new Date())
    );
  };

  /** Generate a cryptographically-random 64-hex-char API key. */
  Organization.generateApiKey = () => randomBytes(32).toString("hex");

  return Organization;
};
