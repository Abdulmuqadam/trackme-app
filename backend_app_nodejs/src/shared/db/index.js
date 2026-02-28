const dbConfig = require("../config/database");
const { Sequelize, DataTypes } = require("sequelize");

const sequelize = new Sequelize(
  dbConfig.database,
  dbConfig.user,
  dbConfig.password,
  {
    host: dbConfig.host,
    dialect: dbConfig.dialect,
    operatorsAliases: false,

    pool: {
      max: dbConfig.pool.max,
      min: dbConfig.pool.min,
      acquire: dbConfig.pool.acquire,
      idle: dbConfig.pool.idle,
    },
  }
);

sequelize
  .authenticate()
  .then(() => {
    console.log("connected...");
  })
  .catch((err) => {
    console.log("error" + err);
  });

const db = {};

db.Sequelize = Sequelize;
db.sequelize = sequelize;

db.Organizations = require("../../features/organizations/organization.model")(sequelize, DataTypes);
db.Users = require("../../features/users/user.model")(sequelize, DataTypes);
db.facilitators = require("../../features/facilitators/facilitator.model")(sequelize, DataTypes);
db.Queries = require("../../features/queries/query.model")(sequelize, DataTypes);
db.Messages = require("../../features/chat/message.model")(sequelize, DataTypes);

// Associations
db.Organizations.hasMany(db.Users, { foreignKey: "organization_id" });
db.Users.belongsTo(db.Organizations, { foreignKey: "organization_id" });

db.Organizations.hasMany(db.facilitators, { foreignKey: "organization_id" });
db.facilitators.belongsTo(db.Organizations, { foreignKey: "organization_id" });

db.Organizations.hasMany(db.Queries, { foreignKey: "organization_id" });
db.Queries.belongsTo(db.Organizations, { foreignKey: "organization_id" });

db.sequelize
  .sync({ force: false })
  .then(() => {
    console.log("Yes, Re-sync is done!");
  });

module.exports = db;
