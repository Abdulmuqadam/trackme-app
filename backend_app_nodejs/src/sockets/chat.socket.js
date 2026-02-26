/**
 * Socket.io chat handler using private rooms.
 *
 * Room naming convention: `chat:<userA>:<userB>` where userA < userB
 * (alphabetically sorted) so both sides join the same room regardless
 * of who initiates.
 *
 * Events emitted by the client:
 *   - "join_room"  { sender, receiver }   – join the private room
 *   - "message"    { message, receiver }  – send a message in the room
 *
 * Events emitted to the client:
 *   - "message"    { message, senderUsername, sentAt }
 */
const registerChatSocket = (io) => {
  io.on("connection", (socket) => {
    const username = socket.handshake.query.username;

    // Join a private room between two participants
    socket.on("join_room", ({ sender, receiver }) => {
      if (!sender || !receiver) return;
      const roomId = getRoomId(sender, receiver);
      socket.join(roomId);
    });

    // Send a message only to the private room
    socket.on("message", ({ message, receiver }) => {
      if (!message || !receiver || !username) return;
      const roomId = getRoomId(username, receiver);
      const payload = {
        message,
        senderUsername: username,
        sentAt: Date.now(),
      };
      io.to(roomId).emit("message", payload);
    });
  });
};

/**
 * Returns a deterministic room ID for a pair of usernames.
 * Sorting ensures both "alice→bob" and "bob→alice" resolve to the same room.
 */
const getRoomId = (a, b) => {
  const [first, second] = [a, b].sort();
  return `chat:${first}:${second}`;
};

module.exports = { registerChatSocket };
