const mongoose = require('mongoose');

const tableSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
  },
  isUsing: {
    type: Boolean,
    default: false, // Ban đầu là chưa sử dụng
  },
  totalPrice: {
    type: Number,
    default: 0,
  },
  timeUsed: {
    type: Number,
    default: 0,
  },
});

const Table = mongoose.model('Table', tableSchema);

module.exports = Table;
