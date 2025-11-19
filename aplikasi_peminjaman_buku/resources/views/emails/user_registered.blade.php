@component('mail::message')
# Halo, {{ $nama }} 👋

Akun Anda telah berhasil **terdaftar** di aplikasi *Peminjaman Buku*.

Silakan login untuk mulai menggunakan layanan kami.

@component('mail::button', ['url' => 'https://your-app-domain.com/login'])
Login Sekarang
@endcomponent

Terima kasih,<br>
<b>Perpustakaan Digital</b>
@endcomponent
