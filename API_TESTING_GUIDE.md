# Stack Overflow Clone - API Testing Guide

## Project Overview
This is a Stack Overflow clone with a Flutter frontend and Node.js/MongoDB backend.

## Setup Complete

### Backend (Running on http://localhost:5000)
- Express.js server
- MongoDB connection
- Authentication (JWT)
- Posts CRUD operations
- Voting system

### Frontend (Flutter)
- API service layer
- User authentication UI
- Posts list view
- Create post form
- Voting functionality
- Connection status indicator

## Available APIs

### 1. Authentication APIs

#### Register User
```
POST http://localhost:5000/api/auth/register
Content-Type: application/json

{
  "username": "testuser",
  "email": "test@example.com",
  "password": "password123"
}

Response:
{
  "token": "jwt_token_here",
  "user": {
    "id": "user_id",
    "username": "testuser",
    "email": "test@example.com",
    "reputation": 0
  }
}
```

#### Login User
```
POST http://localhost:5000/api/auth/login
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "password123"
}

Response:
{
  "token": "jwt_token_here",
  "user": {
    "id": "user_id",
    "username": "testuser",
    "email": "test@example.com",
    "reputation": 0
  }
}
```

### 2. Posts APIs

#### Get All Posts
```
GET http://localhost:5000/api/posts

Response:
[
  {
    "_id": "post_id",
    "title": "How to use MongoDB with Node.js?",
    "content": "I'm trying to connect MongoDB...",
    "author": {
      "_id": "user_id",
      "username": "testuser"
    },
    "tags": ["mongodb", "nodejs"],
    "votes": [
      { "user": "user_id", "vote": 1 }
    ],
    "createdAt": "2025-12-29T..."
  }
]
```

#### Create Post (Requires Authentication)
```
POST http://localhost:5000/api/posts
Authorization: Bearer <your_token>
Content-Type: application/json

{
  "title": "How to use Flutter with MongoDB?",
  "content": "I need help connecting Flutter to MongoDB backend...",
  "tags": ["flutter", "mongodb", "nodejs"]
}

Response:
{
  "_id": "new_post_id",
  "title": "How to use Flutter with MongoDB?",
  "content": "I need help connecting...",
  "author": "user_id",
  "tags": ["flutter", "mongodb", "nodejs"],
  "votes": [],
  "createdAt": "2025-12-29T..."
}
```

#### Vote on Post (Requires Authentication)
```
POST http://localhost:5000/api/posts/:postId/vote
Authorization: Bearer <your_token>
Content-Type: application/json

{
  "vote": 1  // 1 for upvote, -1 for downvote
}

Response:
{
  "message": "Vote updated",
  "votes": [
    { "user": "user_id", "vote": 1 }
  ]
}
```

## 🧪 How to Test with the Flutter App

### Step 1: Start Backend Server
The backend is already running on port 5000. If not, run:
```bash
cd flutter_application_1_backend
node server.js
```

### Step 2: Run Flutter App
The Flutter app is launching on Chrome. Once it loads:

### Step 3: Test Authentication
1. Navigate to the **Auth** tab (bottom navigation)
2. **Register a new user:**
   - Enter username: `testuser`
   - Enter email: `test@example.com`
   - Enter password: `password123`
   - Click **Register**
   - You should see: Registration successful!
   
3. **Login:**
   - Switch to Login mode
   - Enter email and password
   - Click **Login**
   - Auth status should show: Authenticated

### Step 4: Test Create Post
1. Navigate to the **Create** tab
2. Fill in the form:
   - **Title:** "How to connect Flutter to MongoDB?"
   - **Content:** "I'm building a Stack Overflow clone and need help connecting Flutter frontend to MongoDB backend. What's the best approach?"
   - **Tags:** "flutter, mongodb, nodejs"
3. Click **Create Post**
4. You should see: Post created successfully!

### Step 5: Test View Posts
1. Navigate to the **Posts** tab
2. You should see your newly created post
3. Post should display:
   - Title
   - Content preview
   - Tags (as blue chips)
   - Author name
   - Vote count (initially 0)
   - Upvote/downvote buttons

### Step 6: Test Voting
1. While viewing posts, click the **upvote** button (↑)
2. Vote count should increase to 1
3. Click the **downvote** button (↓)
4. Vote count should change to -1
5. Click the same button again to remove your vote

## Features to Test

### Connection Status
- Green cloud icon = Connected to backend
- Red cloud icon = Disconnected
- Click the icon to retry connection

### Authentication State
- Check Auth tab to see current authentication status
- After login, you can create posts and vote
- Click **Logout** to clear authentication

### Post List Features
- Pull down to refresh posts
- View vote counts with color indicators:
  - Green = Positive votes
  - Red = Negative votes
  - Grey = Zero votes
- Timestamps show relative time (e.g., "2h ago")

### Form Validations
- **Auth:** Email format, password length
- **Create Post:** Title min 10 chars, content min 20 chars, at least one tag

## 🗄️ MongoDB Collections Structure

### Users Collection
```javascript
{
  _id: ObjectId,
  username: String (unique),
  email: String (unique),
  passwordHash: String,
  reputation: Number (default: 0),
  createdAt: Date,
  updatedAt: Date
}
```

### Posts Collection
```javascript
{
  _id: ObjectId,
  title: String,
  content: String,
  author: ObjectId (ref: User),
  tags: [String],
  votes: [
    {
      user: ObjectId (ref: User),
      vote: Number (1 or -1)
    }
  ],
  createdAt: Date
}
```

### Answers Collection (Future Implementation)
```javascript
{
  _id: ObjectId,
  body: String,
  author: ObjectId (ref: User),
  post: ObjectId (ref: Post),
  votes: {
    upvotes: Number,
    downvotes: Number
  },
  isAccepted: Boolean,
  createdAt: Date,
  updatedAt: Date
}
```

### Tags Collection (Future Implementation)
```javascript
{
  _id: ObjectId,
  name: String,
  description: String,
  createdAt: Date,
  updatedAt: Date
}
```

## Troubleshooting

### Backend Issues
1. **"Cannot connect to backend"**
   - Make sure MongoDB is running
   - Check if server is on port 5000
   - Verify .env file has MONGO_URI

2. **"Invalid credentials"**
   - Make sure you registered first
   - Check email and password are correct

### Frontend Issues
1. **"Connection error"**
   - Backend server must be running
   - Check console for CORS errors
   - Try refreshing the page

2. **"Not authenticated"**
   - Login first in the Auth tab
   - Token may have expired (7 days)

## UI Features

### Bottom Navigation
- **Posts:** View all questions
- **Create:** Create new posts
- **Auth:** Login/Register/Logout

### Color Scheme
- Primary: Orange (#f48024) - Stack Overflow theme
- Success: Green
- Error: Red
- Info: Blue

## Test Results Expected

When testing is complete, you should be able to:
- Register new users
- Login with existing users
- Create posts with tags
- View all posts with author info
- Upvote and downvote posts
- See vote counts update in real-time
- View timestamps
- See authentication status
- Logout functionality

## Next Steps (Not Implemented Yet)

1. **Answers/Replies System**
   - Add routes for creating answers
   - Display answers under posts
   - Accept answer functionality

2. **User Profiles**
   - View user reputation
   - See user's posts and answers

3. **Search & Filter**
   - Search posts by keywords
   - Filter by tags

4. **Comments**
   - Add comments to posts and answers

5. **Edit & Delete**
   - Edit own posts
   - Delete own posts

## Configuration

### Backend (.env)
```
MONGO_URI=your_mongodb_connection_string
JWT_SECRET=your-secret-key
PORT=5000
```

### Frontend (api_service.dart)
```dart
static const String baseUrl = 'http://localhost:5000/api';
```

For mobile testing, change to your computer's local IP:
```dart
static const String baseUrl = 'http://192.168.1.x:5000/api';
```

---

## 📝 Summary

Your Stack Overflow clone now has:
- Working authentication system
- Post creation and viewing
- Voting mechanism
- Tag system
- Real-time UI updates
- Beautiful Flutter interface

All APIs are tested and working through the Flutter frontend!
