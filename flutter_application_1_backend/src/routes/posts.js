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

module.exports = router;

