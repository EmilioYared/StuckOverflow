const mongoose = require("mongoose");

const AnswerSchema = new mongoose.Schema(
  {
    body: { type: String, required: true },
    author: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
    post: { type: mongoose.Schema.Types.ObjectId, ref: "Post" },
    votes: [
      {
        user: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
        vote: { type: Number, enum: [1, -1] }
      }
    ],
    isAccepted: { type: Boolean, default: false }
  },
  { timestamps: true }
);

AnswerSchema.virtual('voteCount').get(function() {
  return this.votes.reduce((sum, v) => sum + v.vote, 0);
});

AnswerSchema.virtual('upvotes').get(function() {
  return this.votes.filter(v => v.vote === 1).length;
});

AnswerSchema.virtual('downvotes').get(function() {
  return this.votes.filter(v => v.vote === -1).length;
});

AnswerSchema.set('toJSON', { virtuals: true });
AnswerSchema.set('toObject', { virtuals: true });

module.exports = mongoose.model("Answer", AnswerSchema);
