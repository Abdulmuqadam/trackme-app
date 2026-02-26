# TrackMe – Backend (Node.js / Express)

## Architecture

```
backend_app_nodejs/
├── app.js                         # Express app + server bootstrap
├── .env.example                   # Required environment variables (copy to .env)
├── config/
│   ├── database.js                # Sequelize connection
│   └── jwtToken.js                # JWT helpers
├── controllers/
│   ├── userController.js          # User CRUD & auth
│   ├── facilitatorController.js   # Facilitator CRUD & auth
│   └── queryController.js         # Emergency query logic
├── model/
│   ├── index.js                   # Sequelize model registry
│   ├── userModel.js
│   ├── facilitatorModel.js
│   ├── queryModel.js
│   └── messageModel.js
├── routes/
│   ├── userRouter.js              # POST /api/users/*
│   ├── facilitatorRouter.js       # POST /api/facilitators/*
│   └── queryRouter.js             # POST /api/queries/*
└── src/                           # Reusable infrastructure layer
    ├── middleware/
    │   ├── auth.middleware.js      # JWT Bearer-token authentication
    │   ├── errorHandler.middleware.js  # Centralised error handler
    │   └── rateLimiter.middleware.js   # express-rate-limit presets
    ├── sockets/
    │   └── chat.socket.js         # Socket.io private-room chat
    └── utils/
        ├── asyncHandler.js        # Async route wrapper
        └── logger.js              # HTTP request logger (morgan)
```

## Getting Started

```bash
cp .env.example .env   # fill in your values
npm install
npm start              # nodemon app.js
```

## Environment Variables

See `.env.example` for the full list. The critical ones are:

| Variable | Description |
|---|---|
| `JWT_SECRET` | Long random string used to sign JWTs |
| `DB_*` | MySQL connection details |
| `APP_PORT` | Server port (default 3010) |
| `CORS_ORIGIN` | Allowed origin(s) for CORS |
| `FACILITATOR_RADIUS_KM` | Max search radius for nearby facilitators |

## API Overview

### Users (`/api/users`)
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/signup` | – | Register a new user |
| POST | `/login` | – | Login; returns JWT |
| POST | `/verify` | – | Verify a JWT token |
| GET | `/emailchecker` | – | Check if email is taken |
| POST | `/getuser` | ✅ | Fetch user by ID |
| POST | `/update/:id` | ✅ | Update user profile |

### Facilitators (`/api/facilitators`) – same pattern as Users

### Queries (`/api/queries`)
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/save` | ✅ | Submit an emergency query |
| POST | `/updatelocation` | ✅ | Update facilitator GPS location |
| POST | `/getquerybyfacilitatorid` | ✅ | List queries assigned to a facilitator |
| POST | `/getquerybyusername` | ✅ | List queries posted by a user |
| POST | `/updatequerycomplete` | ✅ | Mark a query complete/incomplete |

## Real-time Chat (Socket.io)

Clients must:
1. Connect with `?username=<username>` query param.
2. Emit `join_room` with `{ sender, receiver }` before sending messages.
3. Emit `message` with `{ message, receiver }` to chat in the private room.

Messages are delivered only to the two participants in the private room.

