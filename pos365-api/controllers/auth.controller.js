const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

// Đăng ký người dùng
exports.register = async (req, res) => {
  try {
    const { username, password } = req.body;

    // Kiểm tra xem tài khoản đã tồn tại hay chưa
    const userExist = await User.findOne({ username });
    if (userExist) return res.status(400).json({ message: 'Tài khoản đã tồn tại' });

    // Mã hóa mật khẩu trước khi lưu vào database
    const hashed = await bcrypt.hash(password, 10);

    // Tạo người dùng mới
    const newUser = new User({ username, password: hashed });
    await newUser.save();

    res.status(201).json({ message: 'Đăng ký thành công' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

// Đăng nhập người dùng
exports.login = async (req, res) => {
  try {
    const { username, password } = req.body;

    // Kiểm tra xem tài khoản có tồn tại không
    const user = await User.findOne({ username });
    if (!user) return res.status(400).json({ message: 'Tài khoản không tồn tại' });

    // Kiểm tra mật khẩu
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(400).json({ message: 'Sai mật khẩu' });

    // Tạo token JWT
    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, { expiresIn: '1d' });

    res.json({ message: 'Đăng nhập thành công', token });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Lỗi server' });
  }
};
