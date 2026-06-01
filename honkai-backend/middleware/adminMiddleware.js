const isAdmin = (req, res, next) => {
    // req.user didapat dari verifyToken yang dijalankan sebelumnya
    if (req.user && req.user.role === 'admin') {
        next();
    } else {
        res.status(403).json({ 
            message: 'Akses ditolak. Fitur ini hanya untuk Admin!' 
        });
    }
};

module.exports = isAdmin;