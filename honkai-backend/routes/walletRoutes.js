const express = require('express');
const router = express.Router();
const db = require('../config/db');
const verifyToken = require('../middleware/authMiddleware');

router.get('/balance', verifyToken, async (req, res) => {
    try {
        const [users] = await db.execute('SELECT wallet FROM users WHERE id = ?', [req.user.id]);
        
        if (users.length === 0) {
            return res.status(404).json({ message: 'User tidak ditemukan' });
        }

        res.json({ balance: users[0].wallet });
    } catch (error) {
        console.error("Error Get Balance:", error.message);
        res.status(500).json({ message: 'Gagal mengambil saldo' });
    }
});

router.get('/transactions', verifyToken, async (req, res) => {
    try {
        const [rows] = await db.execute(
            'SELECT id, type, amount, description, created_at FROM wallet_transactions WHERE user_id = ? ORDER BY created_at DESC',
            [req.user.id]
        );

        res.json(rows); 
    } catch (error) {
        console.error("Error Get Transactions:", error.message);
        res.status(500).json({ message: 'Gagal mengambil riwayat transaksi' });
    }
});

router.post('/topup', verifyToken, async (req, res) => {
    const amount = 50000.00;
    const userId = req.user.id;
    const connection = await db.getConnection();

    try {
        await connection.beginTransaction();

        await connection.execute(
            'UPDATE users SET wallet = wallet + ? WHERE id = ?',
            [amount, userId]
        );

        await connection.execute(
            'INSERT INTO wallet_transactions (user_id, type, amount, description) VALUES (?, ?, ?, ?)',
            [userId, 'topup', amount, 'Top Up Credits']
        );

        await connection.commit();
        console.log(`✅ Topup Berhasil: User ${userId} +${amount}`);

        res.json({ 
            message: 'Berhasil menambah 50.000 Credits!', 
            added: amount 
        });

    } catch (error) {
        await connection.rollback();
        console.error("❌ Error Detail Topup:", error.message);
        res.status(500).json({ message: 'Gagal menambah saldo: ' + error.message });
    } finally {
        connection.release();
    }
});

module.exports = router;