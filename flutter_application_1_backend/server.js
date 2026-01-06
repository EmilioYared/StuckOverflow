const mongoose = require("mongoose");
const app = require("./src/app");
require("dotenv").config();

const PORT = process.env.PORT || 5000;

console.log("Server file loaded");
console.log("MONGO_URI exists:", !!process.env.MONGO_URI);

mongoose
  .connect(process.env.MONGO_URI)
  .then(() => {
    console.log("MongoDB connected");

    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });
  })
  .catch(err => {
    console.error("MongoDB connection error:");
    console.error(err);
  });
