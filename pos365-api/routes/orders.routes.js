const express = require('express');
const router = express.Router();
const ordersController = require('../controllers/orders.controller');

router.post('/', ordersController.createOrder);
router.get('/table/:tableId', ordersController.getOrdersByTable);
router.put('/:id', ordersController.updateOrder);
router.delete('/:id', ordersController.deleteOrder);
router.get('/:id', ordersController.getOrderById);

module.exports = router;
