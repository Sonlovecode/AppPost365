const Table = require('../models/table.model');

// Lấy danh sách bàn
exports.getTables = async (req, res) => {
  try {
    const tables = await Table.find();
    res.json(tables); // Trả về danh sách bàn
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server khi lấy bàn', error: err.message });
  }
};

// Cập nhật trạng thái bàn
exports.updateTable = async (req, res) => {
  try {
    const table = await Table.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!table) {
      return res.status(404).json({ message: 'Bàn không tồn tại' });
    }
    res.json(table); // Trả về bàn sau khi cập nhật
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server khi cập nhật bàn', error: err.message });
  }
};

// Thêm bàn mới
exports.createTable = async (req, res) => {
  try {
    const { name, isUsing, totalPrice, timeUsed } = req.body;
    const newTable = new Table({ name, isUsing, totalPrice, timeUsed });
    await newTable.save();
    res.status(201).json(newTable); // Trả về bàn mới đã tạo
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server khi thêm bàn', error: error.message });
  }
};

// Xóa bàn
exports.deleteTable = async (req, res) => {
  try {
    const table = await Table.findByIdAndDelete(req.params.id);
    if (!table) {
      return res.status(404).json({ message: 'Bàn không tồn tại' });
    }
    res.json({ message: 'Xóa bàn thành công' });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server khi xóa bàn', error: error.message });
  }
};
