const express = require("express");
require("dotenv").config();
const cors = require("cors");
const helmet = require("helmet");
const http = require("http");
const { Server } = require("socket.io");
const Sentry = require("@sentry/node");

const { requestLogger } = require("./src/utils/logger");
const { apiLimiter } = require("./src/middleware/rateLimiter.middleware");
const { errorHandler } = require("./src/middleware/errorHandler.middleware");
const { registerChatSocket } = require("./src/sockets/chat.socket");

const app = express();

// ── Sentry (must be initialized before any other middleware) ──────────────────
if (process.env.SENTRY_DSN) {
  Sentry.init({
    dsn: process.env.SENTRY_DSN,
    environment: process.env.NODE_ENV || "development",
    tracesSampleRate: process.env.NODE_ENV === "production" ? 0.2 : 1.0,
  });
  app.use(Sentry.expressErrorHandler());
}

const server = http.createServer(app);
const io = new Server(server);

const corsOptions = {
  origin: process.env.CORS_ORIGIN || "*",
  headers: "Origin, X-Requested-With, Content-Type, Accept",
};

// Security & utility middleware
app.use(helmet());
app.use(cors(corsOptions));
app.use(requestLogger);
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true, limit: "10mb" }));

// Global rate limiter
app.use("/api", apiLimiter);

// Routes
const user_router = require("./routes/userRouter");
const facilitator_router = require("./routes/facilitatorRouter");
const query_router = require("./routes/queryRouter");
const organization_router = require("./routes/organizationRouter");
app.use("/api/users", user_router);
app.use("/api/facilitators", facilitator_router);
app.use("/api/queries", query_router);
app.use("/api/organizations", organization_router);

// Health-check endpoint
app.get("/", (req, res) => {
  res.json({ message: "TrackMe API is running", status: "ok" });
});

// Socket.io – private room chat
registerChatSocket(io);

// Centralized error handler (must be last)
app.use(errorHandler);

// Start server
const PORT = process.env.APP_PORT || 3010;
server.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
