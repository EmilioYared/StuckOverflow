const express = require("express");
const Post = require("../models/Post");
const auth = require("../middleware/auth");

const router = express.Router();

// Create a new post
router.post("/", auth, async (req, res) => {
  try {
    const post = await Post.create({
      ...req.body,
      author: req.userId
    });
    res.status(201).json(post);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get all posts
router.get("/", async (req, res) => {
  try {
    const posts = await Post.find()
      .populate("author", "username")
      .sort({ createdAt: -1 });

    res.json(posts);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Voting route
router.post('/:postId/vote', auth, async (req, res) => {
  const { postId } = req.params;
  const { vote } = req.body; // vote = 1 or -1
  const userId = req.userId; // from auth middleware

  try {
    const post = await Post.findById(postId);
    if (!post) return res.status(404).json({ message: 'Post not found' });

    const existingVoteIndex = post.votes.findIndex(v => v.user.toString() === userId);

    if (existingVoteIndex !== -1) {
      // Toggle vote if same
      if (post.votes[existingVoteIndex].vote === vote) {
        post.votes.splice(existingVoteIndex, 1);
      } else {
        post.votes[existingVoteIndex].vote = vote;
      }
    } else {
      post.votes.push({ user: userId, vote });
    }

    await post.save();
    res.json({ message: 'Vote updated', votes: post.votes });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Delete a post (with cascading deletes)
router.delete("/:postId", auth, async (req, res) => {
  try {
    const Answer = require("../models/Answer");
    const Comment = require("../models/Comment");

    const post = await Post.findById(req.params.postId);
    if (!post) {
      return res.status(404).json({ message: "Post not found" });
    }

    // Check if user is the author
    if (post.author.toString() !== req.userId) {
      return res.status(403).json({ message: "Not authorized to delete this post" });
    }

    // Find all answers to this post
    const answers = await Answer.find({ post: req.params.postId });
    const answerIds = answers.map(a => a._id);

    // Delete all comments on those answers
    await Comment.deleteMany({ answer: { $in: answerIds } });

    // Delete all comments on the post itself
    await Comment.deleteMany({ post: req.params.postId });

    // Delete all answers
    await Answer.deleteMany({ post: req.params.postId });

    // Delete the post
    await Post.findByIdAndDelete(req.params.postId);

    res.json({ message: "Post and all related content deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;

