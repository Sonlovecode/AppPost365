const express = require('express');
const router = express.Router();
const tableController = require('../controllers/table.controller');

// Lấy danh sách bàn
router.get('/', tableController.getTables);

// Cập nhật trạng thái bàn
router.put('/:id', tableController.updateTable);

// Thêm bàn mới
router.post('/', tableController.createTable);

// Xóa bàn
router.delete('/:id', tableController.deleteTable);

module.exports = router;
