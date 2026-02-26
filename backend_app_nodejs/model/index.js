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

db.Users = require("./userModel")(sequelize, DataTypes);
db.facilitators = require("./facilitatorModel")(sequelize, DataTypes);
db.Queries = require("./queryModel")(sequelize, DataTypes);
db.Messages = require("./messageModel")(sequelize, DataTypes);

db.sequelize
  .sync({
    force: false,
  })
  .then(() => {
    console.log("Yes, Re-sync is done!");
  });

module.exports = db;
