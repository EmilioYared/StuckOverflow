const express = require("express");
const Answer = require("../models/Answer");
const Post = require("../models/Post");
const auth = require("../middleware/auth");

const router = express.Router();

// Get all answers for a post
router.get("/post/:postId", async (req, res) => {
  try {
    const answers = await Answer.find({ post: req.params.postId })
      .populate("author", "username reputation")
      .sort({ createdAt: -1 });

    res.json(answers);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Create an answer
router.post("/", auth, async (req, res) => {
  try {
    const { body, post } = req.body;

    // Check if post exists
    const postExists = await Post.findById(post);
    if (!postExists) {
      return res.status(404).json({ message: "Post not found" });
    }

    const answer = await Answer.create({
      body,
      author: req.userId,
      post,
    });

    // Populate author info before returning
    await answer.populate("author", "username reputation");

    res.status(201).json(answer);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Upvote an answer
router.post("/:answerId/upvote", auth, async (req, res) => {
  try {
    const answer = await Answer.findById(req.params.answerId);
    if (!answer) {
      return res.status(404).json({ message: "Answer not found" });
    }

    answer.votes.upvotes += 1;
    await answer.save();

    res.json({ message: "Upvoted", votes: answer.votes });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Downvote an answer
router.post("/:answerId/downvote", auth, async (req, res) => {
  try {
    const answer = await Answer.findById(req.params.answerId);
    if (!answer) {
      return res.status(404).json({ message: "Answer not found" });
    }

    answer.votes.downvotes += 1;
    await answer.save();

    res.json({ message: "Downvoted", votes: answer.votes });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Mark answer as accepted
router.post("/:answerId/accept", auth, async (req, res) => {
  try {
    const answer = await Answer.findById(req.params.answerId).populate("post");
    if (!answer) {
      return res.status(404).json({ message: "Answer not found" });
    }

    // Check if user is the post author
    if (answer.post.author.toString() !== req.userId) {
      return res.status(403).json({ message: "Only post author can accept answers" });
    }

    // Unaccept all other answers for this post
    await Answer.updateMany(
      { post: answer.post._id, _id: { $ne: answer._id } },
      { isAccepted: false }
    );

    // Accept this answer
    answer.isAccepted = !answer.isAccepted;
    await answer.save();

    res.json({ message: answer.isAccepted ? "Answer accepted" : "Answer unaccepted", answer });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
