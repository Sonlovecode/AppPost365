const express = require('express');
const router = express.Router();
const foodItemController = require('../controllers/foodItem.controller');

// POST /api/food-items - Tạo món ăn
router.post('/', foodItemController.createFoodItem);

// GET /api/food-items - Lấy tất cả món ăn
router.get('/', foodItemController.getAllFoodItems);

module.exports = router;
