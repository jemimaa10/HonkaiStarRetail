const express = require('express');
const router = express.Router();
const db = require('../config/db');
const verifyToken = require('../middleware/authMiddleware');

router.get('/', verifyToken, async (req, res) => {
    try {
        const [items] = await db.execute(
            `SELECT i.quantity, p.name, p.type, p.image_url 
             FROM inventory i 
             JOIN products p ON i.product_id = p.id 
             WHERE i.user_id = ?`,
            [req.user.id]
        );
        res.json({ inventory: items });
    } catch (error) {
        res.status(500).json({ message: 'Gagal mengambil inventory' });
    }
});

router.post('/buy', verifyToken, async (req, res) => {
    const { product_id, quantity } = req.body;
    const connection = await db.getConnection();

    try {
        await connection.beginTransaction();

        const [products] = await connection.execute('SELECT * FROM products WHERE id = ?', [product_id]);
        const [users] = await connection.execute('SELECT wallet FROM users WHERE id = ?', [req.user.id]);
        
        const product = products[0];
        const user = users[0];
        const totalPrice = product.price * quantity;

        if (product.stock < quantity) {
            throw new Error('Stok tidak mencukupi!');
        }

        if (user.wallet < totalPrice) {
            throw new Error('Saldo tidak cukup!');
        }

        await connection.execute('UPDATE users SET wallet = wallet - ? WHERE id = ?', [totalPrice, req.user.id]);
        await connection.execute('UPDATE products SET stock = stock - ? WHERE id = ?', [quantity, product_id]);

        await connection.execute(
            `INSERT INTO inventory (user_id, product_id, quantity) 
             VALUES (?, ?, ?) 
             ON DUPLICATE KEY UPDATE quantity = quantity + ?`,
            [req.user.id, product_id, quantity, quantity]
        );

        await connection.execute(
            'INSERT INTO wallet_transactions (user_id, type, amount, description) VALUES (?, ?, ?, ?)',
            [req.user.id, 'purchase', -totalPrice, `Beli ${product.name}`]
        );

        await connection.commit();
        res.json({ message: 'Pembelian berhasil!' });
    } catch (error) {
        await connection.rollback();
        res.status(400).json({ message: error.message });
    } finally {
        connection.release();
    }
});

module.exports = router;