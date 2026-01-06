const express = require("express");
const Comment = require("../models/Comment");
const auth = require("../middleware/auth");

const router = express.Router();

router.post("/", auth, async (req, res) => {
  try {
    console.log("Creating comment with data:", req.body);
    const { content, type, post, answer, mentions } = req.body;

    const comment = await Comment.create({
      content,
      type,
      post,
      answer,
      mentions,
      author: req.userId,
      metadata: {
        ipAddress: req.ip,
        userAgent: req.get("user-agent"),
        flags: 0
      }
    });

    console.log("Comment created:", comment._id);

    await comment.populate("author", "username reputation");

    console.log("Comment populated, sending response");
    res.status(201).json(comment);
  } catch (error) {
    console.error("Error creating comment:", error);
    res.status(500).json({ message: error.message });
  }
});

router.get("/", async (req, res) => {
  try {
    const comments = await Comment.find()
      .populate("author", "username reputation")
      .populate("post", "title")
      .populate("answer", "body")
      .sort({ createdAt: -1 });

    res.json(comments);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get("/post/:postId", async (req, res) => {
  try {
    const comments = await Comment.find({ post: req.params.postId })
      .populate("author", "username reputation")
      .sort({ createdAt: -1 });

    res.json(comments);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get("/answer/:answerId", async (req, res) => {
  try {
    const comments = await Comment.find({ answer: req.params.answerId })
      .populate("author", "username reputation")
      .sort({ createdAt: -1 });

    res.json(comments);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get("/author/:authorId", async (req, res) => {
  try {
    const comments = await Comment.find({ author: req.params.authorId })
      .populate("post", "title")
      .populate("answer", "body")
      .sort({ createdAt: -1 });

    res.json(comments);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get("/stats/aggregate", async (req, res) => {
  try {
    const stats = await Comment.aggregate([
      {
        $lookup: {
          from: "users",
          localField: "author",
          foreignField: "_id",
          as: "authorDetails"
        }
      },
      {
        $unwind: "$authorDetails"
      },
      {
        $group: {
          _id: "$author",
          username: { $first: "$authorDetails.username" },
          totalComments: { $sum: 1 },
          averageScore: { $avg: "$score" },
          totalScore: { $sum: "$score" },
          commentTypes: { $push: "$type" },
          lastCommentDate: { $max: "$createdAt" }
        }
      },
      {
        $sort: { totalComments: -1 }
      },
      {
        $limit: 10
      }
    ]);

    res.json(stats);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get("/stats/detailed", async (req, res) => {
  try {
    const detailedComments = await Comment.aggregate([
      {
        $lookup: {
          from: "users",
          localField: "author",
          foreignField: "_id",
          as: "authorInfo"
        }
      },
      {
        $lookup: {
          from: "posts",
          localField: "post",
          foreignField: "_id",
          as: "postInfo"
        }
      },
      {
        $lookup: {
          from: "answers",
          localField: "answer",
          foreignField: "_id",
          as: "answerInfo"
        }
      },
      {
        $unwind: {
          path: "$authorInfo",
          preserveNullAndEmptyArrays: true
        }
      },
      {
        $unwind: {
          path: "$postInfo",
          preserveNullAndEmptyArrays: true
        }
      },
      {
        $unwind: {
          path: "$answerInfo",
          preserveNullAndEmptyArrays: true
        }
      },
      {
        $project: {
          content: 1,
          type: 1,
          score: 1,
          createdAt: 1,
          "authorInfo.username": 1,
          "authorInfo.reputation": 1,
          "postInfo.title": 1,
          "answerInfo.body": 1
        }
      },
      {
        $sort: { createdAt: -1 }
      },
      {
        $limit: 20
      }
    ]);

    res.json(detailedComments);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.put("/:commentId", auth, async (req, res) => {
  try {
    const comment = await Comment.findById(req.params.commentId);

    if (!comment) {
      return res.status(404).json({ message: "Comment not found" });
    }

    if (comment.author.toString() !== req.userId) {
      return res.status(403).json({ message: "Not authorized to update this comment" });
    }

    const oldContent = comment.content;
    
    if (req.body.content) {
      comment.content = req.body.content;
      comment.isEdited = true;
      
      if (!comment.metadata.editHistory) {
        comment.metadata.editHistory = [];
      }
      comment.metadata.editHistory.push({
        editedAt: new Date(),
        previousContent: oldContent
      });
    }

    if (req.body.status) {
      comment.status = req.body.status;
    }

    if (req.body.mentions) {
      comment.mentions = req.body.mentions;
    }

    await comment.save();
    await comment.populate("author", "username reputation");

    res.json(comment);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post("/:commentId/upvote", auth, async (req, res) => {
  try {
    const comment = await Comment.findById(req.params.commentId);

    if (!comment) {
      return res.status(404).json({ message: "Comment not found" });
    }

    comment.score += 1;
    await comment.save();

    res.json({ message: "Comment upvoted", score: comment.score });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.delete("/:commentId", auth, async (req, res) => {
  try {
    const comment = await Comment.findById(req.params.commentId);

    if (!comment) {
      return res.status(404).json({ message: "Comment not found" });
    }

    if (comment.author.toString() !== req.userId) {
      return res.status(403).json({ message: "Not authorized to delete this comment" });
    }

    await Comment.findByIdAndDelete(req.params.commentId);

    res.json({ message: "Comment deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
