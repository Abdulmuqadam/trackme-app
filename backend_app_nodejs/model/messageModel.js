const { DataTypes } = require("sequelize");
const { sequelize } = require(".");

module.exports = (sequelize, DataTypes) => {
  const message = sequelize.define("message", {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    message: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    sender: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    receiver: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    sendAt: {
      type: DataTypes.DATE,
      allowNull: true,
    },
  });
};
