const express = require('express');
const router = express.Router();
const db = require('../config/db');
const verifyToken = require('../middleware/authMiddleware');
const isAdmin = require('../middleware/adminMiddleware');

router.get('/', verifyToken, async (req, res) => {
    try {
        const [products] = await db.execute('SELECT * FROM products ORDER BY created_at DESC');
        res.json({ message: 'Berhasil mengambil data produk', data: products });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Gagal mengambil data produk' });
    }
});

router.post('/', verifyToken, isAdmin, async (req, res) => {
    const { name, type, description, stock, image_url, price } = req.body;

    if (!name || !type || !stock || !image_url || !price) {
        return res.status(400).json({ message: 'Semua field wajib diisi (kecuali description)!' });
    }

    try {
        const [result] = await db.execute(
            'INSERT INTO products (name, type, description, stock, image_url, price, created_by) VALUES (?, ?, ?, ?, ?, ?, ?)',
            [name, type, description || null, stock, image_url, price, req.user.id]
        );
        
        res.status(201).json({ message: 'Produk berhasil ditambahkan!', productId: result.insertId });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Gagal menambahkan produk' });
    }
});

router.put('/:id', verifyToken, isAdmin, async (req, res) => {
    const productId = req.params.id;
    const { name, type, description, stock, image_url, price } = req.body;

    try {
        const [result] = await db.execute(
            'UPDATE products SET name = ?, type = ?, description = ?, stock = ?, image_url = ?, price = ? WHERE id = ?',
            [name, type, description || null, stock, image_url, price, productId]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Produk tidak ditemukan!' });
        }

        res.json({ message: 'Produk berhasil diperbarui!' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Gagal memperbarui produk' });
    }
});

router.delete('/:id', verifyToken, isAdmin, async (req, res) => {
    const productId = req.params.id;

    try {
        const [result] = await db.execute('DELETE FROM products WHERE id = ?', [productId]);

        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Produk tidak ditemukan!' });
        }

        res.json({ message: 'Produk berhasil dihapus!' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Gagal menghapus produk' });
    }
});

module.exports = router;