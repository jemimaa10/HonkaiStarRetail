const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;



// Middleware dasar
app.use(cors()); // Mengizinkan akses dari frontend Flutter
app.use(express.json()); // Membaca body request berbentuk JSON
app.use(express.urlencoded({ extended: true }));

// Test Route sederhana
app.get('/', (req, res) => {
    res.json({ message: 'Selamat datang di API Honkai Star Retail!' });
});

// ==========================================
// Rangkuman Import Routes (Akan kita isi bertahap)
// ==========================================
const authRoutes = require('./routes/authRoutes');
const productRoutes = require('./routes/productRoutes');
const cartRoutes = require('./routes/cartRoutes');
const inventoryRoutes = require('./routes/inventoryRoutes');
const walletRoutes = require('./routes/walletRoutes');

app.use('/api/auth', authRoutes);
app.use('/api/products', productRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/inventory', inventoryRoutes);
app.use('/api/wallet', walletRoutes);

// Jalankan serverrrrr
app.listen(PORT, () => {
    console.log(`🚀 Server berjalan di http://localhost:${PORT}`);
});