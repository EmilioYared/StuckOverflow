const express = require("express");
const cors = require("cors");

const app = express();

app.use(cors());
app.use(express.json());

app.get("/", (req, res) => {
  res.send("API is running");
});

const postRoutes = require("./routes/posts");
app.use("/api/posts", postRoutes);

const authRoutes = require("./routes/auth");
app.use("/api/auth", authRoutes);

const answerRoutes = require("./routes/answers");
app.use("/api/answers", answerRoutes);

module.exports = app;
