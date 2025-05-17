const Order = require('../models/order.model');
const FoodItem = require('../models/foodItem.model');
const Table = require('../models/table.model'); // cần file model Table

exports.createOrder = async (req, res) => {
  const { tableId, foodId, quantity } = req.body;

  if (!tableId || !foodId || !quantity) {
    return res.status(400).json({ message: 'Thiếu thông tin!' });
  }

  try {
    const foodItem = await FoodItem.findById(foodId);
    if (!foodItem) {
      return res.status(404).json({ message: 'Món ăn không tồn tại!' });
    }

    const totalPrice = foodItem.price * quantity;

    const newOrder = new Order({
      tableId,
      foodId,
      quantity,
      totalPrice,
    });

    await newOrder.save();

    res.status(201).json(newOrder);
  } catch (error) {
    console.error('Lỗi khi tạo đơn hàng:', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
};
