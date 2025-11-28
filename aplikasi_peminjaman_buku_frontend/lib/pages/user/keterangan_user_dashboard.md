lib/
├── main.dart
├── services/
│   └── api_service.dart          <-- Semua logic API masuk sini
└── pages/
    ├── login_page.dart
    ├── admin_dashboard.dart
    └── user/                     <-- Folder khusus User
        ├── user_dashboard.dart   <-- Hanya kerangka (Navbar & Scaffold)
│       ├── user_home.dart       (Halaman Home)
│       ├── user_search.dart     (Halaman Cari Buku & Logic Pinjam)
│       ├── user_loans.dart      (Halaman Pinjaman Saya)
│       └── user_profile.dart    (Halaman Profil)