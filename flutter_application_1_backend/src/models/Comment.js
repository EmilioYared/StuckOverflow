const mongoose = require("mongoose");

const CommentSchema = new mongoose.Schema(
  {
    // String field with validation rule (minlength)
    content: {
      type: String,
      required: true,
      minlength: [3, "Comment must be at least 3 characters long"],
      maxlength: 500,
      trim: true
    },
    
    // String field with lowercase constraint
    status: {
      type: String,
      lowercase: true,
      default: "approved"
    },
    
    // String field with enum constraint
    type: {
      type: String,
      enum: {
        values: ["question", "answer", "general"],
        message: "{VALUE} is not a valid comment type"
      },
      required: true,
      default: "general"
    },
    
    // Votes array (like Posts/Answers)
    votes: [
      {
        user: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
        vote: { type: Number, enum: [1] } // Comments only support upvotes
      }
    ],
    
    // Number field with maximum value (kept for backward compatibility)
    score: {
      type: Number,
      default: 0,
      max: [1000, "Score cannot exceed 1000"],
      min: 0
    },
    
    // Boolean field
    isEdited: {
      type: Boolean,
      default: false
    },
    
    // Array field
    mentions: {
      type: [String],
      default: []
    },
    
    // JSON-like field (Object/Mixed type)
    metadata: {
      type: {
        editHistory: [{
          editedAt: Date,
          previousContent: String
        }],
        ipAddress: String,
        userAgent: String,
        flags: Number
      },
      default: {}
    },
    
    // Foreign Key to User collection
    author: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true
    },
    
    // Foreign Key to Post collection (optional - either post or answer)
    post: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Post"
    },
    
    // Foreign Key to Answer collection (optional - either post or answer)
    answer: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Answer"
    }
  },
  { 
    timestamps: true // Automatically adds createdAt and updatedAt Date fields
  }
);

// Virtual field for vote count
CommentSchema.virtual('voteCount').get(function() {
  return this.votes.length;
});

CommentSchema.set('toJSON', { virtuals: true });
CommentSchema.set('toObject', { virtuals: true });

// Index for faster queries
CommentSchema.index({ post: 1, createdAt: -1 });
CommentSchema.index({ answer: 1, createdAt: -1 });
CommentSchema.index({ author: 1 });

// Custom validation: A comment must belong to either a post or an answer
CommentSchema.path('post').validate(function(value) {
  return this.post || this.answer;
}, 'Comment must be associated with either a post or an answer');

CommentSchema.path('post').validate(function(value) {
  return !(this.post && this.answer);
}, 'Comment cannot be associated with both post and answer');

module.exports = mongoose.model("Comment", CommentSchema);
