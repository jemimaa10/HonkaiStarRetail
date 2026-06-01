const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const db = require('../config/db');
const { OAuth2Client } = require('google-auth-library');
const axios = require('axios');

// Inisialisasi Google Client ID dari .env
const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

/**
 * Fungsi bantuan untuk generate JWT Token aplikasi kita
 */
const generateToken = (user) => {
    return jwt.sign(
        { id: user.id, role: user.role },
        process.env.JWT_SECRET,
        { expiresIn: '7d' } 
    );
};

/**
 * 1. Endpoint Login Google (Hybrid: Mendukung ID Token & Access Token)
 */
router.post('/google-login', async (req, res) => {
    const { idToken } = req.body; 

    if (!idToken) {
        return res.status(400).json({ message: 'Token Google tidak ditemukan!' });
    }

    try {
        let payload;

        // LANGKAH 1: Coba verifikasi sebagai ID TOKEN (Biasanya dari Mobile/Android)
        try {
            const ticket = await client.verifyIdToken({
                idToken: idToken,
                audience: process.env.GOOGLE_CLIENT_ID, 
            });
            payload = ticket.getPayload();
        } catch (e) {
            // LANGKAH 2: Jika gagal, coba verifikasi sebagai ACCESS TOKEN (Sering dari Flutter Web)
            console.log("Verifikasi ID Token gagal, mencoba verifikasi via Google UserInfo API...");
            const response = await axios.get(`https://www.googleapis.com/oauth2/v3/userinfo?access_token=${idToken}`);
            payload = response.data;
            
            // Map data dari UserInfo API agar strukturnya sama dengan ticket.getPayload()
            if (payload && !payload.sub) payload.sub = payload.id;
            if (payload && !payload.picture) payload.picture = payload.avatar;
        }

        if (!payload || (!payload.email && !payload.sub)) {
            throw new Error("Gagal mendapatkan data valid dari Google.");
        }

        const { email, name, sub: google_id, picture: avatar_url } = payload;

        // 2. Cek apakah user sudah ada di database
        let [users] = await db.execute('SELECT * FROM users WHERE email = ?', [email]);
        let user = users[0];

        if (!user) {
            // Jika belum ada, otomatis register sebagai 'user'
            const [result] = await db.execute(
                'INSERT INTO users (name, email, google_id, role, avatar_url, wallet) VALUES (?, ?, ?, ?, ?, ?)',
                [name || 'Trailblazer', email, google_id, 'user', avatar_url || null, 0]
            );
            
            const [newUsers] = await db.execute('SELECT * FROM users WHERE id = ?', [result.insertId]);
            user = newUsers[0];
        } else {
            // Jika email sudah ada, pastikan google_id dan avatar diperbarui
            await db.execute(
                'UPDATE users SET google_id = ?, avatar_url = ? WHERE id = ?',
                [google_id, avatar_url || user.avatar_url, user.id]
            );

            // Ambil ulang data terbaru dari DB
            const [updatedUsers] = await db.execute('SELECT * FROM users WHERE id = ?', [user.id]);
            user = updatedUsers[0];
        }

        // 3. Generate JWT Token untuk sesi di aplikasi
        const token = generateToken(user);

        res.json({
            success: true,
            message: 'Login Google berhasil!',
            token: token,
            user: { 
                id: user.id, 
                name: user.name, 
                email: user.email, 
                role: user.role, 
                wallet: user.wallet, 
                avatar_url: user.avatar_url 
            }
        });

    } catch (error) {
        console.error('Google Login Error:', error.message);
        res.status(401).json({ message: 'Otentikasi Google gagal atau token tidak valid.' });
    }
});

/**
 * 2. Endpoint Login Manual (Email & Password)
 */
router.post('/login', async (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
        return res.status(400).json({ message: 'Email dan password harus diisi!' });
    }

    try {
        const [users] = await db.execute('SELECT * FROM users WHERE email = ?', [email]);
        const user = users[0];

        if (!user || !user.password) {
            return res.status(401).json({ message: 'Akun tidak ditemukan atau gunakan Login Google.' });
        }

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(401).json({ message: 'Email atau password salah!' });
        }

        const token = generateToken(user);

        res.json({
            success: true,
            message: 'Login berhasil!',
            token: token,
            user: { 
                id: user.id, 
                name: user.name, 
                email: user.email, 
                role: user.role, 
                wallet: user.wallet, 
                avatar_url: user.avatar_url 
            }
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Terjadi kesalahan pada server.' });
    }
});

/**
 * 3. Endpoint Register Manual
 */
router.post('/register', async (req, res) => {
    const { name, email, password } = req.body;

    if (!name || !email || !password) {
        return res.status(400).json({ message: 'Data tidak lengkap!' });
    }

    try {
        const [existingUsers] = await db.execute('SELECT * FROM users WHERE email = ?', [email]);
        if (existingUsers.length > 0) {
            return res.status(400).json({ message: 'Email sudah terdaftar!' });
        }

        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        const [result] = await db.execute(
            'INSERT INTO users (name, email, password, role, wallet) VALUES (?, ?, ?, ?, ?)',
            [name, email, hashedPassword, 'user', 0]
        );

        res.status(201).json({
            success: true,
            message: 'Registrasi berhasil! Silakan login.',
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Gagal melakukan registrasi.' });
    }
});

module.exports = router;