// const Bill = require('../models/bill.model');
// const Order = require('../models/order.model');
// const Table = require('../models/table.model');

// // Tạo hóa đơn mới
// exports.createBill = async (req, res) => {
//   try {
//     const { tableId, totalAmount, discount, paymentMethod, items } = req.body;

//     if (!tableId || !totalAmount || !items || !Array.isArray(items)) {
//       return res.status(400).json({ message: 'Thiếu thông tin cần thiết hoặc danh sách món không hợp lệ' });
//     }

//     const table = await Table.findById(tableId);
//     if (!table) {
//       return res.status(404).json({ message: 'Không tìm thấy bàn' });
//     }

//     const newBill = new Bill({
//       tableId,
//       totalAmount,
//       discount: discount || 0,
//       paymentMethod: paymentMethod || 'Tiền mặt',
//       items,
//     });

//     await newBill.save();

//     // Xoá toàn bộ đơn hàng của bàn
//     await Order.deleteMany({ tableId });

//     // Cập nhật trạng thái bàn
//     table.isUsing = false;
//     table.totalPrice = 0;
//     await table.save();

//     res.status(201).json({
//       message: 'Tạo hóa đơn thành công',
//       bill: newBill,
//     });
//   } catch (error) {
//     console.error('Lỗi khi tạo hóa đơn:', error);
//     res.status(500).json({ message: 'Lỗi server khi tạo hóa đơn' });
//   }
// };

// // Lấy danh sách hóa đơn
// exports.getAllBills = async (req, res) => {
//   try {
//     const bills = await Bill.find().sort({ createdAt: -1 });
//     res.status(200).json(bills);
//   } catch (error) {
//     console.error('Lỗi khi lấy danh sách hóa đơn:', error);
//     res.status(500).json({ message: 'Lỗi server khi lấy danh sách hóa đơn' });
//   }
// };

// // Lấy hóa đơn theo ID
// exports.getBillById = async (req, res) => {
//   try {
//     const bill = await Bill.findById(req.params.id);
//     if (!bill) {
//       return res.status(404).json({ message: 'Không tìm thấy hóa đơn' });
//     }
//     res.status(200).json(bill);
//   } catch (error) {
//     console.error('Lỗi khi lấy chi tiết hóa đơn:', error);
//     res.status(500).json({ message: 'Lỗi server khi lấy chi tiết hóa đơn' });
//   }
// };

// // Lấy hóa đơn theo khoảng thời gian
// exports.getBillsByDateRange = async (req, res) => {
//   try {
//     const { startDate, endDate } = req.query;

//     if (!startDate || !endDate) {
//       return res.status(400).json({ message: 'Vui lòng cung cấp ngày bắt đầu và kết thúc' });
//     }

//     const start = new Date(startDate);
//     const end = new Date(endDate);
//     end.setHours(23, 59, 59, 999);

//     const bills = await Bill.find({
//       createdAt: { $gte: start, $lte: end },
//     }).sort({ createdAt: -1 });

//     res.status(200).json(bills);
//   } catch (error) {
//     console.error('Lỗi khi lọc hóa đơn theo thời gian:', error);
//     res.status(500).json({ message: 'Lỗi server khi lọc hóa đơn theo thời gian' });
//   }
// };
