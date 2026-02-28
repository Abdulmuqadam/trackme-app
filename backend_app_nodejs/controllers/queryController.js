const db = require("../model");
const { getDistance } = require("geolib");
const { upload, uploadAudioToS3 } = require("../src/middleware/upload.middleware");
const { GetObjectCommand } = require("@aws-sdk/client-s3");
const { getSignedUrl } = require("@aws-sdk/s3-request-presigner");
const s3 = require("../config/s3");

const Query = db.Queries;
const Facilitator = db.facilitators;

const QUERY_TYPE_TO_ROLE = {
  "Home Invasion": "Police",
  "Medical Help": "Ambulance",
  "Fire Extinguisher": "Rescue",
  "Travel Emergency": "Road Assistance",
};

const MAX_RADIUS_KM = parseInt(process.env.FACILITATOR_RADIUS_KM || "15", 10);

/**
 * Parse a "lat,lon" string into { latitude, longitude }.
 * Returns null if the string is malformed.
 */
const parseCoords = (coordStr) => {
  if (!coordStr) return null;
  const parts = coordStr.split(",").map(parseFloat);
  if (parts.length !== 2 || parts.some(isNaN)) return null;
  return { latitude: parts[0], longitude: parts[1] };
};

const saveQuery = async (req, res) => {
  try {
    const { text, querytype, postedBy, completed, location } = req.body;

    if (!querytype || !postedBy || !req.file) {
      return res
        .status(400)
        .json({ error: "querytype, postedBy, and audio file are required" });
    }

    const role = QUERY_TYPE_TO_ROLE[querytype];
    if (!role) {
      return res.status(400).json({ error: "Invalid query type" });
    }

    const baseCoords = parseCoords(location);
    if (!baseCoords) {
      return res.status(400).json({ error: "Invalid or missing location" });
    }

    // Upload audio to S3
    const audioKey = await uploadAudioToS3(req.file);

    const facilitators = await Facilitator.findAll({ where: { role } });

    if (facilitators.length === 0) {
      return res
        .status(404)
        .json({ error: `No ${role} available near the specified location` });
    }

    // Use geolib to find the nearest facilitator within MAX_RADIUS_KM
    let nearestFacilitator = null;
    let minDistanceM = Infinity;

    for (const facilitator of facilitators) {
      const coords = parseCoords(facilitator.location);
      if (!coords) continue;
      const distanceM = getDistance(baseCoords, coords);
      if (distanceM <= MAX_RADIUS_KM * 1000 && distanceM < minDistanceM) {
        minDistanceM = distanceM;
        nearestFacilitator = facilitator;
      }
    }

    if (!nearestFacilitator) {
      return res
        .status(404)
        .json({ error: `No ${role} available within ${MAX_RADIUS_KM} km` });
    }

    await Query.create({
      text,
      querytype,
      audio_url: audioKey,
      postedBy,
      assignedTo: nearestFacilitator.id,
      completed,
      location,
    });

    res.status(201).json({
      message: "Query saved successfully",
      location: nearestFacilitator.location,
      facilitator_id: nearestFacilitator.id,
    });
  } catch (error) {
    console.error("Error saving query:", error);
    res.status(500).json({ error: "Failed to save query" });
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

/**
 * GET /api/queries/:id/audio-url
 * Returns a pre-signed S3 URL valid for 1 hour.
 */
const getAudioUrl = async (req, res) => {
  try {
    const query = await Query.findByPk(req.params.id);
    if (!query || !query.audio_url) {
      return res.status(404).json({ error: "Audio not found" });
    }
    const command = new GetObjectCommand({
      Bucket: process.env.S3_BUCKET_NAME,
      Key: query.audio_url,
    });
    const url = await getSignedUrl(s3, command, { expiresIn: 3600 });
    res.json({ url });
  } catch (error) {
    console.error("Error generating audio URL:", error);
    res.status(500).json({ error: "Failed to generate audio URL" });
  }
};

module.exports = {
  saveQuery,
  postLocation,
  getQueryByFacilitatorid,
  updateCompletion,
  getQueryByUserName,
  getAudioUrl,
  uploadMiddleware: upload.single("audio"),
};
