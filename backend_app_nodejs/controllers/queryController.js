const db = require("../model");
const multer = require("multer");
const path = require("path");
const geolib = require("geolib");
const { where } = require("sequelize");
const fs = require("fs");

const Query = db.Queries;
const Facilitator = db.facilitators;

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, "uploads/");
  },
  filename: function (req, file, cb) {
    let datetimestamp = Date.now();
    cb(null, datetimestamp + path.extname(file.originalname));
  },
});

const uploads = multer({ storage: storage });

function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371; // Radius of the Earth in kilometers
  const dLat = deg2rad(lat2 - lat1);
  const dLon = deg2rad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(deg2rad(lat1)) *
      Math.cos(deg2rad(lat2)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  const distance = R * c; // Distance in kilometers
  return distance;
}

function deg2rad(deg) {
  return deg * (Math.PI / 180);
}

function findNearbyLocations(baseLocation, locations, maxDistance) {
  const [baseLat, baseLon] = baseLocation.split(",").map(parseFloat);
  const nearbyLocations = [];

  for (const loc of locations) {
    const [lat, lon] = loc.split(",").map(parseFloat);
    const distance = calculateDistance(baseLat, baseLon, lat, lon);
    if (distance <= maxDistance) {
      nearbyLocations.push({ location: loc, distance: distance });
    }
  }

  return nearbyLocations;
}

function findNearestLocation(locations) {
  let minDistance = Infinity;
  let nearestLocation = null;

  for (const loc of locations) {
    if (loc.distance < minDistance) {
      minDistance = loc.distance;
      nearestLocation = loc.location;
    }
  }

  return nearestLocation;
}

const writeAudioFile = async (base64Audio, filePath) => {
  try {
    const audioData = Buffer.from(base64Audio, "base64");

    fs.writeFileSync(filePath, audioData);

    console.log("Audio file written successfully:", filePath);
  } catch (error) {
    console.error("Failed to write audio file:", error);
    throw error;
  }
};

const saveQuery = async (req, res) => {
  try {
    // Destructure fields from the request body
    const { text, querytype, audio, postedBy, completed, location } = req.body;

    // Ensure required fields are present
    if (!querytype || !postedBy || !audio) {
      return res
        .status(400)
        .json({ error: "querytype, postedBy, and audio are required" });
    }

    // Define the role based on query type
    let role;
    switch (querytype) {
      case "Home Invasion":
        role = "Police";
        break;
      case "Medical Help":
        role = "Ambulance";
        break;
      case "Fire Extinguisher":
        role = "Rescue";
        break;
      case "Travel Emergency":
        role = "Road Assistance";
        break;
      default:
        return res.status(400).json({ error: "Invalid query type" });
    }

    // Query Location
    const baseLocation = location;
    const maxDistance = 15;

    // Query facilitator data based on role
    const facilitators = await Facilitator.findAll({
      where: { role },
    });

    if (facilitators.length > 0) {
      const facilitatorLocations = facilitators.map(
        (facilitator) => facilitator.location
      );

      const locations = facilitatorLocations;
      const nearbyLocations = findNearbyLocations(
        baseLocation,
        locations,
        maxDistance
      );
      const nearestLocation = findNearestLocation(nearbyLocations);

      const facilitator = await Facilitator.findOne({
        where: { location: nearestLocation },
      });
      if (facilitator) {
        // Save the data to the database with the assigned facilitator's ID
        const data = await Query.create({
          text,
          querytype,
          audio,
          postedBy,
          assignedTo: facilitator.id,
          completed,
          location,
        });

        // Respond with success message and saved data
        res.status(201).json({
          message: "Data is successfully saved",
          location: facilitator.location,
          facilitator_id: facilitator.id,
        });
      }
    } else {
      return res
        .status(404)
        .json({ error: `No ${role} available near the specified location` });
    }
  } catch (error) {
    console.error("Error saving data:", error);
    res.status(500).json({ error: "Failed to save data" });
  }
};

const getQueryByFacilitatorid = async (req, res) => {
  try {
    const { facilitatorID } = req.body;
    if (!facilitatorID) {
      return res.status(400).json({ error: "ID is not found" });
    }
    const queries = await Query.findAll({
      where: { assignedTo: facilitatorID },
    });
    if (queries.length === 0) {
      return res
        .status(404)
        .json({ message: "No queries found for the provided ID" });
    }
    res.status(200).json({ message: "Queries found", queries });
  } catch (error) {
    console.error("Failed to get queries by facilitator ID:", error);
    res.status(500).json({ error: "Failed to get data" });
  }
};

const getQueryByUserName = async (req, res) => {
  try {
    const { userName } = req.body;
    if (!userName) {
      return res.status(400).json({ error: "User name is not found" });
    }
    const queries = await Query.findAll({ where: { postedBy: userName } });
    if (queries.length === 0) {
      return res
        .status(404)
        .json({ message: "No queries found for the provided ID" });
    }
    res.status(200).json({ message: "Queries found", queries });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Internal Server error", error: e });
  }
};

const postLocation = async (req, res) => {
  try {
    const { userId, location } = req.body;
    if (!userId || !location) {
      return res
        .status(400)
        .json({ error: "user id and location is required" });
    }
    await Facilitator.update({ location: location }, { where: { id: userId } });
    res.status(200).json({ message: "location updated successfully" });
  } catch (error) {
    console.error("Failed to process location:", error);
    res.status(500).json({ error: "Internal server error" });
  }
};

const updateCompletion = async (req, res) => {
  try {
    const { id, completed } = req.body;
    if (
      typeof completed !== "boolean" ||
      completed === undefined ||
      id === undefined
    ) {
      return res
        .status(400)
        .json({ error: "Id and Completed (as a boolean) are required" });
    }

    const result = await Query.update(
      { completed: completed },
      { where: { id: id } }
    );
    // res.status(200).json(result);
    if (result[0] === 1) {
      res.status(200).json({ message: "Query is marked as completed" });
    } else {
      res.status(404).json({ error: "Query not found" });
    }
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: "Internal Server error" });
  }
};

module.exports = {
  saveQuery,
  postLocation,
  getQueryByFacilitatorid,
  updateCompletion,
  getQueryByUserName,
};
