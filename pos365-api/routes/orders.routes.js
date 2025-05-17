// routes/orders.routes.js
const express = require('express');
const router = express.Router();
const ordersController = require('../controllers/orders.controller');

// Đặt món (tạo đơn hàng)
router.post('/', ordersController.createOrder);

module.exports = router;
