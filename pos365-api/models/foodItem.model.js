const mongoose = require('mongoose');

// Mô hình món ăn
const foodItemSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
  },
  price: {
    type: Number,
    required: true,
  },
});

const FoodItem = mongoose.model('FoodItem', foodItemSchema);

module.exports = FoodItem;
