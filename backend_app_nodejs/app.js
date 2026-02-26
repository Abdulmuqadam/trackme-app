const express = require("express");
require("dotenv").config();
const cors = require("cors");
const app = express();
const http = require("http");
const server = http.createServer(app);
const { Server } = require("socket.io"); // For real time data transfer
const io = new Server(server);
const messages = [];

var corsOptions = {
  origin: "*",
  headers: "Origin, X-Requested-With, Content-Type, Accept",
}; //For data send to server

// Middleware
app.use(cors(corsOptions));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
const user_router = require("./routes/userRouter");
const facilitator_router = require("./routes/facilitatorRouter");
const query_router = require("./routes/queryRouter");
app.use("/api/users", user_router);
app.use("/api/facilitators", facilitator_router);
app.use("/api/queries", query_router);

// Testing API
app.get("/", (req, res) => {
  res.json({ message: "Hello From API" });
});

// Socket.io
io.on("connection", (socket) => {
  const username = socket.handshake.query.username;
  socket.on("message", (data) => {
    const message = {
      message: data.message,
      senderUsername: username,
      sentAt: Date.now(),
    };
    messages.push(message);
    console.log(messages);
    io.emit("message", message);
  });
});

// Port
const PORT = process.env.APP_PORT || 3010;

// Listen to the server
server.listen(PORT, () => {
  console.log(`Server is running on ${PORT}`);
});
