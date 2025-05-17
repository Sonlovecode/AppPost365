const FoodItem = require('../models/foodItem.model');

// Lấy tất cả món ăn
exports.getAllFoodItems = async (req, res) => {
  try {
    const foodItems = await FoodItem.find();
    res.status(200).json(foodItems);
  } catch (err) {
    console.error('Lỗi khi lấy món ăn:', err);
    res.status(500).json({ message: err.message });
  }
};

// Tạo món ăn mới
exports.createFoodItem = async (req, res) => {
  const { name, price } = req.body;

  if (!name || !price) {
    return res.status(400).json({ message: 'Tên món ăn và giá là bắt buộc' });
  }

  try {
    const newFoodItem = new FoodItem({ name, price });
    await newFoodItem.save();
    res.status(201).json(newFoodItem);
  } catch (err) {
    console.error('Lỗi khi tạo món ăn:', err);
    res.status(500).json({ message: 'Lỗi máy chủ khi tạo món ăn' });
  }
};
