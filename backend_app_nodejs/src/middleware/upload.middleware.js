const multer = require("multer");
const { PutObjectCommand } = require("@aws-sdk/client-s3");
const { randomUUID } = require("crypto");
const s3 = require("../../config/s3");

/** In-memory multer storage – file bytes are available at req.file.buffer */
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 }, // 10 MB
  fileFilter: (_req, file, cb) => {
    if (file.mimetype.startsWith("audio/")) {
      cb(null, true);
    } else {
      cb(new Error("Only audio files are allowed"), false);
    }
  },
});

/**
 * Upload a multer file object to S3.
 * Returns the S3 object key (not the full URL).
 */
const uploadAudioToS3 = async (file) => {
  const ext = file.originalname.split(".").pop() || "mp3";
  const key = `audio/${randomUUID()}.${ext}`;

  await s3.send(
    new PutObjectCommand({
      Bucket: process.env.S3_BUCKET_NAME,
      Key: key,
      Body: file.buffer,
      ContentType: file.mimetype,
    })
  );

  return key;
};

module.exports = { upload, uploadAudioToS3 };
