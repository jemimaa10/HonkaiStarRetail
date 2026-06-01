const jwt = require('jsonwebtoken');

const verifyToken = (req, res, next) => {
    // 1. Ambil header 'Authorization' dari request
    const authHeader = req.headers['authorization'];
    
    // 2. Cek apakah header ada dan formatnya benar (Bearer <token>) [cite: 54]
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(403).json({ 
            message: 'Akses ditolak. Format Bearer token salah atau tidak ditemukan!' 
        });
    }

    // 3. Ekstrak token aslinya
    const token = authHeader.split(' ')[1];

    try {
        // 4. Verifikasi token menggunakan secret key dari .env [cite: 57]
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        
        // 5. Simpan data user yang didecode (id, role) ke dalam objek request
        // Ini akan digunakan oleh isAdmin middleware nanti
        req.user = decoded;
        
        // 6. Lanjut ke fungsi/middleware berikutnya
        next();
    } catch (error) {
        return res.status(401).json({ 
            message: 'Token tidak valid atau sudah kedaluwarsa!' 
        });
    }
};

module.exports = verifyToken;