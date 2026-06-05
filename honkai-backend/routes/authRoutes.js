const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const db = require('../config/db');
const { OAuth2Client } = require('google-auth-library');
const axios = require('axios');

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

const generateToken = (user) => {
    return jwt.sign(
        { id: user.id, role: user.role },
        process.env.JWT_SECRET,
        { expiresIn: '7d' } 
    );
};

router.post('/google-login', async (req, res) => {
    const { idToken } = req.body; 

    if (!idToken) {
        return res.status(400).json({ message: 'Google token not found!' });
    }

    try {
        let payload;

        try {
            const ticket = await client.verifyIdToken({
                idToken: idToken,
                audience: process.env.GOOGLE_CLIENT_ID, 
            });
            payload = ticket.getPayload();
        } catch (e) {
            console.log("Token ID verification failed, try verify via Google UserInfo API");
            const response = await axios.get(`https://www.googleapis.com/oauth2/v3/userinfo?access_token=${idToken}`);
            payload = response.data;
            
            if (payload && !payload.sub) payload.sub = payload.id;
            if (payload && !payload.picture) payload.picture = payload.avatar;
        }

        if (!payload || (!payload.email && !payload.sub)) {
            throw new Error("Failed to get valid data from Google");
        }

        const { email, name, sub: google_id, picture: avatar_url } = payload;

        let [users] = await db.execute('SELECT * FROM users WHERE email = ?', [email]);
        let user = users[0];

        if (!user) {
            const [result] = await db.execute(
                'INSERT INTO users (name, email, google_id, role, avatar_url, wallet) VALUES (?, ?, ?, ?, ?, ?)',
                [name || 'Trailblazer', email, google_id, 'user', avatar_url || null, 0]
            );
            
            const [newUsers] = await db.execute('SELECT * FROM users WHERE id = ?', [result.insertId]);
            user = newUsers[0];
        } else {
            await db.execute(
                'UPDATE users SET google_id = ?, avatar_url = ? WHERE id = ?',
                [google_id, avatar_url || user.avatar_url, user.id]
            );

            const [updatedUsers] = await db.execute('SELECT * FROM users WHERE id = ?', [user.id]);
            user = updatedUsers[0];
        }

        const token = generateToken(user);

        res.json({
            success: true,
            message: 'Google login success!',
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
        res.status(401).json({ message: 'Google authentication failed or invalid token' });
    }
});


router.post('/login', async (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
        return res.status(400).json({ message: 'Email and password are required!' });
    }

    try {
        const [users] = await db.execute('SELECT * FROM users WHERE email = ?', [email]);
        const user = users[0];

        if (!user || !user.password) {
            return res.status(401).json({ message: 'Account not found or use Google Login.' });
        }

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(401).json({ message: 'Email or password is incorrect!' });
        }

        const token = generateToken(user);

        res.json({
            success: true,
            message: 'Login successful!',
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
        res.status(500).json({ message: 'A problem occurred on the server.' });
    }
});

router.post('/register', async (req, res) => {
    const { name, email, password } = req.body;

    if (!name || !email || !password) {
        return res.status(400).json({ message: 'Data not complete!' });
    }

    try {
        const [existingUsers] = await db.execute('SELECT * FROM users WHERE email = ?', [email]);
        if (existingUsers.length > 0) {
            return res.status(400).json({ message: 'Email already registered!' });
        }

        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        const [result] = await db.execute(
            'INSERT INTO users (name, email, password, role, wallet) VALUES (?, ?, ?, ?, ?)',
            [name, email, hashedPassword, 'user', 0]
        );

        res.status(201).json({
            success: true,
            message: 'Registration successful! Please login.',
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Failed to register.' });
    }
});

module.exports = router;