const mongoose = require("mongoose");

const AnswerSchema = new mongoose.Schema(
  {
    body: { type: String, required: true },
    author: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
    post: { type: mongoose.Schema.Types.ObjectId, ref: "Post" },
    votes: {
      upvotes: { type: Number, default: 0 },
      downvotes: { type: Number, default: 0 }
    },
    isAccepted: { type: Boolean, default: false }
  },
  { timestamps: true }
);

module.exports = mongoose.model("Answer", AnswerSchema);
