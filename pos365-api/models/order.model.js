// models/order.model.js
const mongoose = require('mongoose');

const orderSchema = new mongoose.Schema({
  tableId: {
    type: String,
    required: true,
  },
  foodId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'FoodItem', // Liên kết đến model FoodItem
    required: true,
  },
  quantity: {
    type: Number,
    required: true,
    default: 1,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('Order', orderSchema);
