const express = require("express");
const Answer = require("../models/Answer");
const Post = require("../models/Post");
const auth = require("../middleware/auth");

const router = express.Router();

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

router.post("/", auth, async (req, res) => {
  try {
    const { body, post } = req.body;

    const postExists = await Post.findById(post);
    if (!postExists) {
      return res.status(404).json({ message: "Post not found" });
    }

    const answer = await Answer.create({
      body,
      author: req.userId,
      post,
    });

    await answer.populate("author", "username reputation");

    res.status(201).json(answer);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

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

router.post("/:answerId/accept", auth, async (req, res) => {
  try {
    const answer = await Answer.findById(req.params.answerId).populate("post");
    if (!answer) {
      return res.status(404).json({ message: "Answer not found" });
    }

    if (answer.post.author.toString() !== req.userId) {
      return res.status(403).json({ message: "Only post author can accept answers" });
    }

    await Answer.updateMany(
      { post: answer.post._id, _id: { $ne: answer._id } },
      { isAccepted: false }
    );

    answer.isAccepted = !answer.isAccepted;
    await answer.save();

    res.json({ message: answer.isAccepted ? "Answer accepted" : "Answer unaccepted", answer });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.delete("/:answerId", auth, async (req, res) => {
  try {
    const Comment = require("../models/Comment");

    const answer = await Answer.findById(req.params.answerId);
    if (!answer) {
      return res.status(404).json({ message: "Answer not found" });
    }

    if (answer.author.toString() !== req.userId) {
      return res.status(403).json({ message: "Not authorized to delete this answer" });
    }

    await Comment.deleteMany({ answer: req.params.answerId });

    await Answer.findByIdAndDelete(req.params.answerId);

    res.json({ message: "Answer and all related comments deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
