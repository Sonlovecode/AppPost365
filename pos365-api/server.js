const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');
dotenv.config(); // Load biến môi trường từ .env

const app = express();

// Middleware
app.use(cors()); // Cho phép tất cả nguồn truy cập
app.use(express.json()); // Parse body JSON

// Import routes
const authRoutes = require('./routes/auth.routes'); // Đảm bảo đã import đúng
const tableRoutes = require('./routes/table.routes');
const foodItemsRouter = require('./routes/food_items.routes'); 
const ordersRoutes = require('./routes/orders.routes');

// Route mapping
app.use('/api', authRoutes); // Sử dụng các route từ auth.routes.js
app.use('/api/tables', tableRoutes); 
app.use('/api/food-items', foodItemsRouter); 
app.use('/api/orders', ordersRoutes);

// Kết nối MongoDB
mongoose.connect(process.env.MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true
})
.then(() => {
  console.log('✅ Kết nối MongoDB thành công');
  app.listen(process.env.PORT || 3000, () => {
    console.log(`🚀 Server đang chạy tại http://localhost:${process.env.PORT || 3000}`);
  });
})
.catch(err => {
  console.error('❌ Lỗi kết nối MongoDB:', err.message);
});
