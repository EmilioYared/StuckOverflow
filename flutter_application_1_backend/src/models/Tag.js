const mongoose = require("mongoose");

const TagSchema = new mongoose.Schema(
  {
    name: { type: String, unique: true, required: true },
    description: String,
    usageCount: { type: Number, default: 0 }
  },
  { timestamps: true }
);

module.exports = mongoose.model("Tag", TagSchema);
