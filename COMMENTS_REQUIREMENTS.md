# Comments System - MongoDB Requirements Documentation

## Schema Requirements

### 1. Field Types
- **String**: `content`, `status`, `type`
- **Integer/Number**: `score` (with max validation)
- **Date**: `createdAt`, `updatedAt` (via timestamps)
- **Boolean**: `isEdited`
- **Array**: `mentions` (array of strings)
- **JSON/Object**: `metadata` (nested object with editHistory)
- **Foreign Keys**: `author` (User), `post` (Post), `answer` (Answer)

### 2. String Constraints
#### First String Field (status):
```javascript
status: {
  type: String,
  lowercase: true,
  default: "approved"
}
```

#### Second String Field (type):
```javascript
type: {
  type: String,
  enum: {
    values: ["question", "answer", "general"],
    message: "{VALUE} is not a valid comment type"
  },
  required: true,
  default: "general"
}
```

### 3. Number Field with Maximum Value
```javascript
score: {
  type: Number,
  default: 0,
  max: [1000, "Score cannot exceed 1000"],
  min: 0
}
```

### 4. Validation Rule
```javascript
content: {
  type: String,
  required: true,
  minlength: [3, "Comment must be at least 3 characters long"],
  maxlength: 500,
  trim: true
}

CommentSchema.pre("save", function(next) {
  if (!this.post && !this.answer) {
    next(new Error("Comment must be associated with either a post or an answer"));
  }
});
```

## CRUD Operations

### CREATE - Insert Record
```javascript
POST /api/comments
Body: {
  "content": "Great answer!",
  "type": "answer",
  "answer": "answer_id_here"
}
```

### READ - Display with Multiple Criteria

#### Criteria: ALL
```javascript
GET /api/comments
// Returns all comments with populated author, post, and answer
```

#### Criteria 1: By Post
```javascript
GET /api/comments/post/:postId
// Returns all comments for a specific post
```

#### Criteria 2: By Answer
```javascript
GET /api/comments/answer/:answerId
// Returns all comments for a specific answer
```

#### Additional Criteria 3: By Author
```javascript
GET /api/comments/author/:authorId
// Returns all comments by a specific author
```

### UPDATE - Update Record
```javascript
PUT /api/comments/:commentId
Body: {
  "content": "Updated comment text",
  "mentions": ["@user1", "@user2"]
}
// Tracks edit history in metadata.editHistory
```

## Populate (JOIN)

### Basic Populate Example
```javascript
const comments = await Comment.find({ post: postId })
  .populate("author", "username reputation")
  .populate("post", "title")
  .populate("answer", "body")
  .sort({ createdAt: -1 });
```

**Endpoint**: `GET /api/comments/post/:postId`

## Aggregate (JOIN)

### Aggregate Example 1: User Comment Statistics
```javascript
GET /api/comments/stats/aggregate

// Uses $lookup (JOIN), $group, $sort
// Returns top commenters with statistics
```

**Pipeline Stages:**
1. `$lookup` - JOIN with users collection
2. `$unwind` - Flatten author array
3. `$group` - Group by author with calculations
4. `$sort` - Sort by total comments
5. `$limit` - Top 10 results

### Aggregate Example 2: Detailed Comments with All Relations
```javascript
GET /api/comments/stats/detailed

// Uses multiple $lookup to JOIN users, posts, and answers
// Returns comments with full related data
```

**Pipeline Stages:**
1. `$lookup` - JOIN with users (author)
2. `$lookup` - JOIN with posts
3. `$lookup` - JOIN with answers
4. Multiple `$unwind` - Flatten arrays
5. `$project` - Select specific fields
6. `$sort` - Sort by date
7. `$limit` - Limit results

## Testing Endpoints

### 1. Create a Comment on a Post
```bash
POST http://localhost:5000/api/comments
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

{
  "content": "This is a great question!",
  "type": "question",
  "post": "POST_ID_HERE"
}
```

### 2. Create a Comment on an Answer
```bash
POST http://localhost:5000/api/comments
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

{
  "content": "Thanks for this detailed answer!",
  "type": "answer",
  "answer": "ANSWER_ID_HERE",
  "mentions": ["@username"]
}
```

### 3. Get All Comments
```bash
GET http://localhost:5000/api/comments
```

### 4. Get Comments by Post
```bash
GET http://localhost:5000/api/comments/post/POST_ID
```

### 5. Get Comments by Answer
```bash
GET http://localhost:5000/api/comments/answer/ANSWER_ID
```

### 6. Get Comment Statistics (Aggregate)
```bash
GET http://localhost:5000/api/comments/stats/aggregate
```

### 7. Get Detailed Comments (Aggregate with Multiple JOINs)
```bash
GET http://localhost:5000/api/comments/stats/detailed
```

### 8. Update a Comment
```bash
PUT http://localhost:5000/api/comments/COMMENT_ID
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

{
  "content": "Updated comment content",
  "mentions": ["@user1", "@user2"]
}
```

### 9. Upvote a Comment
```bash
POST http://localhost:5000/api/comments/COMMENT_ID/upvote
Authorization: Bearer YOUR_TOKEN
```

### 10. Delete a Comment
```bash
DELETE http://localhost:5000/api/comments/COMMENT_ID
Authorization: Bearer YOUR_TOKEN
```

## Summary of Requirements Met

**Schema with all field types**: String, Integer, Date, Boolean, Array, JSON  
**Foreign keys**: author, post, answer  
**String constraints**: lowercase (status), enum (type)  
**Number constraint**: max value (score)  
**Validation rule**: minlength on content  
**Display criteria**: ALL, by Post, by Answer, by Author  
**Populate**: Fetches related User, Post, Answer data  
**Aggregate**: Two examples with $lookup (JOIN), $group, $sort  
**CRUD operations**: Create, Read, Update, Delete  

## Database Schema Visualization

```
Comment Collection
├── _id: ObjectId
├── content: String (min 3, max 500) Validation
├── status: String (lowercase) Lowercase constraint
├── type: String (enum: question/answer/general) Enum constraint
├── score: Number (max 1000) Max value constraint
├── isEdited: Boolean
├── mentions: [String] Array
├── metadata: Object JSON/Object
│   ├── editHistory: Array
│   ├── ipAddress: String
│   ├── userAgent: String
│   └── flags: Number
├── author: ObjectId → User Foreign Key
├── post: ObjectId → Post Foreign Key
├── answer: ObjectId → Answer Foreign Key
├── createdAt: Date Auto-generated
└── updatedAt: Date Auto-generated
```
