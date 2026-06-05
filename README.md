# Honkai Star Retail

Aplikasi marketplace bertema Honkai Star Rail yang dibuat menggunakan:

- Flutter (Frontend)
- Node.js + Express.js (Backend)
- MySQL (Database)
- JWT Authentication
- Google OAuth Login
- Role Management (Admin & User)

---

# Teknologi

Frontend:
- Flutter
- Provider
- HTTP Package
- Google Sign In

Backend:
- Node.js
- Express.js
- JWT
- bcrypt
- MySQL2
- dotenv

Database:
- MySQL

---

# Clone Repository

```bash
git clone https://github.com/jemimaa10/HonkaiStarRetail.git
```

Masuk ke folder project:

```bash
cd Honkai Star Retail
```

---

# Backend Setup

Masuk ke folder backend:

```bash
cd honkai-backend
```

Install dependency:

```bash
npm install
```

---

# Database Setup

copas aja langsung semua dari db.txt, abis masuk xampp langsung ke "sql" aja terus copas semua itu, gausah buat db soalnya di code nya udah ada command buat create database nya 


# Google OAuth Setup

Project ini menggunakan Google OAuth melalui Google Cloud Console.

## 1. Buat Project Baru

Buka:

https://console.cloud.google.com

Klik:

```text
Create Project
```

---

## 2. Configure OAuth Consent Screen

Masuk ke:

```text
APIs & Services
→ OAuth Consent Screen
```

Pilih:

```text
External
```

Isi:

```text
App Name:
Honkai Star Retail

User Support Email:
email_kamu@gmail.com

Developer Email:
email_kamu@gmail.com
```

Save.

---

## 3. Create OAuth Client

Masuk ke:

```text
cari APIs & Services di search bar
→ Credentials
→ Create Credentials
→ OAuth Client ID
```

Pilih:

```text
Web Application
```

Contoh:

```text
Name:
Honkai Star Retail Web
```

Authorized JavaScript Origins taro ini:
http://localhost:5000

Authorized redirect URIs taro ini juga sama : 
http://localhost:5000

Setelah dibuat, copy:

```text
Client ID
```

---

## 4. Simpan Client ID

Masukkan ke:

```env
GOOGLE_CLIENT_ID=
```

Contoh:

```env
GOOGLE_CLIENT_ID=123456789-xxxxxxxx.apps.googleusercontent.com
```

---

## 5. ganti .env dengan GOOGLE_CLIENT_ID yang lu dapet

# Menjalankan Backend

```bash
cd honkai-backend
```

```bash
node server.js
```

Server berjalan di:

```text
http://localhost:3000
```

---

# Frontend Setup

buat terminal baru, yang backend jangan ditutup
Masuk ke folder Flutter:

```bash
cd honkai_star_retail
```

Install package:

```bash
flutter pub get
```

---

# Konfigurasi Base URL

Buka:

```text
lib/utils/constants.dart
```

pastiin udah bener:

```dart
class AppConstants {
  static const String baseUrl =
      'http://localhost:3000/api';
}
```

---

# Konfigurasi Google Sign In Flutter

Buka:

```dart
login_page.dart
```

Ganti:

```dart
clientId:
'WEB_CLIENT_ID_KAMU'
```

Dengan Client ID dari Google Cloud Console.

Contoh:

```dart
clientId:
'123456789-xxxxxxxx.apps.googleusercontent.com'
```

---

# Menjalankan Flutter, pake ini jangan langsung flutter run

terminal honkai_star_retail:

```bash
flutter run -d chrome --web-port=5000 --web-hostname=localhost
```

---

# Default Account

Admin:

```text
Email:
admin@honkairetail.com

Password:
admin123
```

User:

```text
Email:
user@honkairetail.com

Password:
user123
```
Update: Untuk mengakses Admin, akun perlu di register secara manual dan di-update rolenya menjadi admin dalam DB.


---

# Notes

- Backend harus berjalan sebelum Flutter dijalankan.
- JWT digunakan untuk autentikasi.
- Endpoint Admin hanya dapat diakses oleh role Admin.
- Google Login membutuhkan OAuth Client ID yang valid.
- Pastikan MySQL aktif sebelum menjalankan backend.

---