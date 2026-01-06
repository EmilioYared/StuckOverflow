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

router.put("/:answerId", auth, async (req, res) => {
  try {
    const answer = await Answer.findById(req.params.answerId);
    if (!answer) {
      return res.status(404).json({ message: "Answer not found" });
    }

    // Check if the user is the author
    if (answer.author.toString() !== req.userId) {
      return res.status(403).json({ message: "Not authorized to edit this answer" });
    }

    answer.body = req.body.body;
    await answer.save();
    await answer.populate("author", "username reputation");

    res.json(answer);
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

    const userId = req.userId;
    const existingVoteIndex = answer.votes.findIndex(v => v.user.toString() === userId);

    if (existingVoteIndex !== -1) {
      // If already upvoted, remove the vote (toggle off)
      if (answer.votes[existingVoteIndex].vote === 1) {
        answer.votes.splice(existingVoteIndex, 1);
      } else {
        // If downvoted, change to upvote
        answer.votes[existingVoteIndex].vote = 1;
      }
    } else {
      // Add new upvote
      answer.votes.push({ user: userId, vote: 1 });
    }

    await answer.save();
    res.json({ message: "Vote updated", votes: { upvotes: answer.upvotes, downvotes: answer.downvotes, total: answer.voteCount } });
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

    const userId = req.userId;
    const existingVoteIndex = answer.votes.findIndex(v => v.user.toString() === userId);

    if (existingVoteIndex !== -1) {
      // If already downvoted, remove the vote (toggle off)
      if (answer.votes[existingVoteIndex].vote === -1) {
        answer.votes.splice(existingVoteIndex, 1);
      } else {
        // If upvoted, change to downvote
        answer.votes[existingVoteIndex].vote = -1;
      }
    } else {
      // Add new downvote
      answer.votes.push({ user: userId, vote: -1 });
    }

    await answer.save();
    res.json({ message: "Vote updated", votes: { upvotes: answer.upvotes, downvotes: answer.downvotes, total: answer.voteCount } });
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
