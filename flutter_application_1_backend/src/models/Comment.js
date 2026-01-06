const mongoose = require("mongoose");

const CommentSchema = new mongoose.Schema(
  {
    content: {
      type: String,
      required: true,
      minlength: [3, "Comment must be at least 3 characters long"],
      maxlength: 500,
      trim: true
    },
    
    status: {
      type: String,
      lowercase: true,
      default: "approved"
    },
    
    type: {
      type: String,
      enum: {
        values: ["question", "answer", "general"],
        message: "{VALUE} is not a valid comment type"
      },
      required: true,
      default: "general"
    },
    
    votes: [
      {
        user: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
        vote: { type: Number, enum: [1] } // Comments only support upvotes
      }
    ],
    
    score: {
      type: Number,
      default: 0,
      max: [1000, "Score cannot exceed 1000"],
      min: 0
    },
    
    isEdited: {
      type: Boolean,
      default: false
    },
    
    mentions: {
      type: [String],
      default: []
    },
    
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
    
    post: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Post"
    },
    
    answer: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Answer"
    }
  },
  { 
    timestamps: true
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
