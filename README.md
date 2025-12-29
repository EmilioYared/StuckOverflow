# Stack Overflow Clone

A full-stack Stack Overflow clone built with Flutter (frontend) and Node.js/MongoDB (backend).

## Features

- ✅ User authentication (register/login with JWT)
- ✅ Create questions with tags
- ✅ Answer questions
- ✅ Upvote/downvote questions and answers
- ✅ Real-time vote counting
- ✅ User reputation system
- ✅ Responsive UI with Stack Overflow theme

## Tech Stack

### Frontend
- Flutter
- Material Design 3
- HTTP package for API calls

### Backend
- Node.js with Express
- MongoDB with Mongoose
- JWT authentication
- bcryptjs for password hashing

## Prerequisites

- Flutter SDK (latest stable version)
- Node.js (v16 or higher)
- MongoDB Atlas account (or local MongoDB)

## Installation

### 1. Clone the repository

```bash
git clone <your-repo-url>
cd StuckOverflow
```

### 2. Backend Setup

```bash
cd flutter_application_1_backend

# Install dependencies
npm install

# Create .env file from example
cp .env.example .env

# Edit .env and add your MongoDB URI and JWT secret
# MONGO_URI=your_mongodb_connection_string
# JWT_SECRET=your_secret_key
# PORT=5000

# Start the server
npm start
# or for development with auto-reload:
npm run dev
```

The backend server will start on `http://localhost:5000`

### 3. Frontend Setup

```bash
cd ../flutter_application_1

# Install dependencies
flutter pub get

# Run the app
flutter run
# Choose your platform: Chrome (web), Windows, etc.
```

## Project Structure

```
StuckOverflow/
├── flutter_application_1/          # Flutter frontend
│   ├── lib/
│   │   ├── models/                 # Data models
│   │   ├── screens/                # UI screens
│   │   ├── services/               # API service
│   │   └── main.dart
│   └── pubspec.yaml
│
└── flutter_application_1_backend/  # Node.js backend
    ├── src/
    │   ├── models/                 # MongoDB schemas
    │   ├── routes/                 # API routes
    │   ├── middleware/             # Auth middleware
    │   └── app.js
    ├── server.js
    └── package.json
```

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user

### Posts (Questions)
- `GET /api/posts` - Get all posts
- `POST /api/posts` - Create post (authenticated)
- `POST /api/posts/:postId/vote` - Vote on post (authenticated)

### Answers
- `GET /api/answers/post/:postId` - Get answers for a post
- `POST /api/answers` - Create answer (authenticated)
- `POST /api/answers/:answerId/upvote` - Upvote answer (authenticated)
- `POST /api/answers/:answerId/downvote` - Downvote answer (authenticated)
- `POST /api/answers/:answerId/accept` - Accept answer (authenticated, post author only)

## Usage

1. **Register/Login**: Go to the Auth tab and create an account or login
2. **Create Post**: Navigate to Create tab and post your question with tags
3. **View Posts**: Browse all questions in the Posts tab
4. **Answer Questions**: Tap on any post to view details and add answers
5. **Vote**: Use upvote/downvote buttons on posts and answers

## Database Schema

### Users Collection
```javascript
{
  username: String (unique),
  email: String (unique),
  passwordHash: String,
  reputation: Number,
  createdAt: Date,
  updatedAt: Date
}
```

### Posts Collection
```javascript
{
  title: String,
  content: String,
  author: ObjectId (ref: User),
  tags: [String],
  votes: [{ user: ObjectId, vote: Number }],
  createdAt: Date
}
```

### Answers Collection
```javascript
{
  body: String,
  author: ObjectId (ref: User),
  post: ObjectId (ref: Post),
  votes: { upvotes: Number, downvotes: Number },
  isAccepted: Boolean,
  createdAt: Date,
  updatedAt: Date
}
```

## Environment Variables

### Backend (.env)
```
MONGO_URI=your_mongodb_connection_string
JWT_SECRET=your_jwt_secret_key
PORT=5000
```

### Frontend
Update `baseUrl` in `lib/services/api_service.dart` if needed:
```dart
static const String baseUrl = 'http://localhost:5000/api';
```

For mobile testing, use your computer's local IP:
```dart
static const String baseUrl = 'http://192.168.1.x:5000/api';
```

## Troubleshooting

### Backend won't start
- Verify MongoDB connection string in .env
- Check if port 5000 is available
- Ensure all dependencies are installed: `npm install`

### Flutter app can't connect
- Verify backend is running on port 5000
- Check the baseUrl in api_service.dart
- For web: ensure CORS is enabled (already configured)


Anyone cloning will just need to:

Run npm install in backend
Create their own .env from .env.example
Run flutter pub get in frontend
Start both servers

### Build errors
- Run `flutter clean` then `flutter pub get`
- Ensure Flutter SDK is up to date: `flutter upgrade`

## Contributing

Feel free to open issues or submit pull requests!

## License

MIT License
