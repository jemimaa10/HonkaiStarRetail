const express = require('express');
const router = express.Router();

const db = require('../config/db');
const verifyToken = require('../middleware/authMiddleware');


router.get('/', verifyToken, async (req, res) => {

    try {

        const [cartItems] = await db.execute(
            `
            SELECT
                cart.id,
                cart.quantity,
                products.id AS product_id,
                products.name,
                products.type,
                products.image_url,
                products.price,
                products.stock
            FROM cart
            JOIN products
                ON cart.product_id = products.id
            WHERE cart.user_id = ?
            ORDER BY cart.added_at DESC
            `,
            [req.user.id]
        );

        res.json({
            message: 'Berhasil mengambil cart',
            data: cartItems
        });

    } catch (error) {

        console.error(error);

        res.status(500).json({
            message: 'Gagal mengambil cart'
        });
    }
});


router.post('/', verifyToken, async (req, res) => {

    const { product_id, quantity } = req.body;

    if (!product_id || !quantity) {
        return res.status(400).json({
            message: 'product_id dan quantity wajib diisi'
        });
    }

    try {

        const [products] = await db.execute(
            'SELECT * FROM products WHERE id = ?',
            [product_id]
        );

        if (products.length === 0) {
            return res.status(404).json({
                message: 'Produk tidak ditemukan'
            });
        }

        const product = products[0];

        if (quantity > product.stock) {
            return res.status(400).json({
                message: 'Stock produk tidak cukup'
            });
        }

        const [existingCart] = await db.execute(
            `
            SELECT * FROM cart
            WHERE user_id = ?
            AND product_id = ?
            `,
            [req.user.id, product_id]
        );

        if (existingCart.length > 0) {

            await db.execute(
                `
                UPDATE cart
                SET quantity = quantity + ?
                WHERE user_id = ?
                AND product_id = ?
                `,
                [quantity, req.user.id, product_id]
            );

        } else {

            await db.execute(
                `
                INSERT INTO cart
                (user_id, product_id, quantity)
                VALUES (?, ?, ?)
                `,
                [req.user.id, product_id, quantity]
            );
        }

        res.status(201).json({
            message: 'Produk berhasil ditambahkan ke cart'
        });

    } catch (error) {

        console.error(error);

        res.status(500).json({
            message: 'Gagal add to cart'
        });
    }
});

router.post('/checkout', verifyToken, async (req, res) => {
    const connection = await db.getConnection();
    try {
        await connection.beginTransaction();

        const [cartItems] = await connection.execute(
            'SELECT c.*, p.price, p.stock, p.name FROM cart c JOIN products p ON c.product_id = p.id WHERE c.user_id = ?',
            [req.user.id]
        );

        if (cartItems.length === 0) throw new Error('Cart kosong!');

        let totalCost = 0;
        for (const item of cartItems) {
            if (item.quantity > item.stock) throw new Error(`Stok ${item.name} tidak cukup!`);
            totalCost += item.price * item.quantity;
        }

        const [user] = await connection.execute('SELECT wallet FROM users WHERE id = ?', [req.user.id]);
        if (user[0].wallet < totalCost) throw new Error('Saldo tidak cukup untuk checkout!');

        await connection.execute(
            'UPDATE users SET wallet = wallet - ? WHERE id = ?', 
            [totalCost, req.user.id]
        );

        await connection.execute(
            'INSERT INTO wallet_transactions (user_id, type, amount, description) VALUES (?, ?, ?, ?)',
            [req.user.id, 'purchase', totalCost, `Purchase of ${cartItems.length} item(s)`]
        );

        for (const item of cartItems) {
            await connection.execute('UPDATE products SET stock = stock - ? WHERE id = ?', [item.quantity, item.product_id]);
            
            await connection.execute(
                'INSERT INTO inventory (user_id, product_id, quantity) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE quantity = quantity + ?',
                [req.user.id, item.product_id, item.quantity, item.quantity]
            );
        }

        await connection.execute('DELETE FROM cart WHERE user_id = ?', [req.user.id]);

        await connection.commit();
        res.json({ message: 'Checkout berhasil, saldo terpotong dan riwayat tercatat!' });

    } catch (error) {
        await connection.rollback();
        console.error("Checkout Error:", error.message);
        res.status(400).json({ message: error.message });
    } finally {
        connection.release();
    }
});


router.put('/:id', verifyToken, async (req, res) => {

    const cartId = req.params.id;
    const { quantity } = req.body;

    if (!quantity || quantity < 1) {
        return res.status(400).json({
            message: 'Quantity minimal 1'
        });
    }

    try {

        const [result] = await db.execute(
            `
            UPDATE cart
            SET quantity = ?
            WHERE id = ?
            AND user_id = ?
            `,
            [quantity, cartId, req.user.id]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({
                message: 'Cart item tidak ditemukan'
            });
        }

        res.json({
            message: 'Quantity cart berhasil diupdate'
        });

    } catch (error) {

        console.error(error);

        res.status(500).json({
            message: 'Gagal update cart'
        });
    }
});


router.delete('/:id', verifyToken, async (req, res) => {

    const cartId = req.params.id;

    try {

        const [result] = await db.execute(
            `
            DELETE FROM cart
            WHERE id = ?
            AND user_id = ?
            `,
            [cartId, req.user.id]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({
                message: 'Cart item tidak ditemukan'
            });
        }

        res.json({
            message: 'Item berhasil dihapus dari cart'
        });

    } catch (error) {

        console.error(error);

        res.status(500).json({
            message: 'Gagal hapus item cart'
        });
    }
});

module.exports = router;