const Order = require('../models/order.model');
const FoodItem = require('../models/foodItem.model');
const Table = require('../models/table.model');

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

    const table = await Table.findById(tableId);
    if (!table) {
      return res.status(404).json({ message: 'Bàn không tồn tại!' });
    }

    if (!table.isUsing) {
      table.isUsing = true;
      await table.save();
    }

    const newOrder = new Order({
      tableId,
      foodId,
      quantity,
    });

    await newOrder.save();
    res.status(201).json(newOrder);
  } catch (error) {
    console.error('Lỗi khi tạo đơn hàng:', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

exports.getOrdersByTable = async (req, res) => {
  try {
    const { tableId } = req.params;
    const orders = await Order.find({ tableId }).populate('foodId', 'name price');

    const formattedOrders = orders.map(order => ({
      _id: order._id,
      tableId: order.tableId,
      quantity: order.quantity,
      createdAt: order.createdAt,
      food: order.foodId,
    }));

    res.status(200).json(formattedOrders);
  } catch (error) {
    console.error('Lỗi khi lấy đơn hàng:', error);
    res.status(500).json({ message: 'Lỗi server khi lấy đơn hàng' });
  }
};

exports.updateOrder = async (req, res) => {
  try {
    const { id } = req.params;
    const { quantity } = req.body;

    if (!quantity || quantity < 1) {
      return res.status(400).json({ message: 'Số lượng không hợp lệ' });
    }

    const order = await Order.findById(id);
    if (!order) {
      return res.status(404).json({ message: 'Không tìm thấy đơn hàng' });
    }

    order.quantity = quantity;
    await order.save();
    res.status(200).json(order);
  } catch (error) {
    console.error('Lỗi khi cập nhật đơn hàng:', error);
    res.status(500).json({ message: 'Lỗi server khi cập nhật đơn hàng' });
  }
};

exports.deleteOrder = async (req, res) => {
  try {
    const { id } = req.params;
    const order = await Order.findByIdAndDelete(id);

    if (!order) {
      return res.status(404).json({ message: 'Không tìm thấy đơn hàng' });
    }

    const remainingOrders = await Order.find({ tableId: order.tableId });

    if (remainingOrders.length === 0) {
      const table = await Table.findById(order.tableId);
      if (table) {
        table.isUsing = false;
        await table.save();
      }
    }

    res.status(200).json({ message: 'Xóa đơn hàng thành công' });
  } catch (error) {
    console.error('Lỗi khi xóa đơn hàng:', error);
    res.status(500).json({ message: 'Lỗi server khi xóa đơn hàng' });
  }
};
// Lấy 1 đơn hàng theo ID
exports.getOrderById = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }
    res.status(200).json(order);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching order', error: error.message });
  }
};
