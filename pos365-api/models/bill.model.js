// const mongoose = require('mongoose');

// const billSchema = new mongoose.Schema({
//   tableId: {
//     type: String,
//     required: true,
//   },
//   totalAmount: {
//     type: Number,
//     required: true,
//   },
//   discount: {
//     type: Number,
//     default: 0,
//   },
//   paymentMethod: {
//     type: String,
//     enum: ['Tiền mặt', 'Thẻ ngân hàng', 'Momo', 'VNPay'],
//     default: 'Tiền mặt',
//   },
//   items: [
//     {
//       foodId: {
//         type: mongoose.Schema.Types.ObjectId,
//         ref: 'FoodItem',
//       },
//       name: String,
//       price: Number,
//       quantity: Number,
//     },
//   ],
//   createdAt: {
//     type: Date,
//     default: Date.now,
//   },
// });

// const Bill = mongoose.model('Bill', billSchema);

// module.exports = Bill;