const express = require('express');
const router = express.Router();
const db = require('../config/db');
const verifyToken = require('../middleware/authMiddleware');

// 1. GET: Cek Saldo User (GET Request ke-1 untuk User)
router.get('/balance', verifyToken, async (req, res) => {
    try {
        const [users] = await db.execute('SELECT wallet FROM users WHERE id = ?', [req.user.id]);
        res.json({ balance: users[0].wallet });
    } catch (error) {
        res.status(500).json({ message: 'Gagal mengambil saldo' });
    }
});

// 2. POST: Tambah Saldo 50.000 (POST Request untuk User)
router.post('/topup', verifyToken, async (req, res) => {
    const amount = 50000.00;
    const connection = await db.getConnection(); // Gunakan transaction agar aman

    try {
        await connection.beginTransaction();

        // Update saldo di tabel users
        await connection.execute(
            'UPDATE users SET wallet = wallet + ? WHERE id = ?',
            [amount, req.user.id]
        );

        // Catat di riwayat transaksi (sesuai skema SQL kamu)
        await connection.execute(
            'INSERT INTO wallet_transactions (user_id, type, amount, description) VALUES (?, ?, ?, ?)',
            [req.user.id, 'topup', amount, 'Daily login bonus / Free credits']
        );

        await connection.commit();
        res.json({ message: 'Berhasil menambah 50.000 Credits!', added: amount });
    } catch (error) {
        await connection.rollback();
        res.status(500).json({ message: 'Gagal menambah saldo' });
    } finally {
        connection.release();
    }
});

module.exports = router;