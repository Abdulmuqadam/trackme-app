module.exports = (sequelize, DataTypes) => {
  const query = sequelize.define("query", {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    text: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    querytype: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    location: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    audio_url: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    postedBy: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    assignedTo: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    completed: {
      type: DataTypes.BOOLEAN,
      allowNull: true,
    },
    organization_id: {
      type: DataTypes.UUID,
      allowNull: true,
    },
  });
  return query;
};
