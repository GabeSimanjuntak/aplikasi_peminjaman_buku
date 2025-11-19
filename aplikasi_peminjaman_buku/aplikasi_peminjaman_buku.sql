CREATE DATABASE aplikasi_peminjaman_buku;
\c aplikasi_peminjaman_buku;

CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    nama_role VARCHAR(50) NOT NULL
);

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL,
    role_id INT NOT NULL REFERENCES roles(id) ON DELETE RESTRICT
);

CREATE TABLE kategori_buku (
    id SERIAL PRIMARY KEY,
    nama_kategori VARCHAR(100) NOT NULL
);

CREATE TABLE buku (
    id SERIAL PRIMARY KEY,
    judul VARCHAR(150) NOT NULL,
    penulis VARCHAR(100),
    penerbit VARCHAR(100),
    tahun VARCHAR(10),
    deskripsi TEXT,
    id_kategori INT REFERENCES kategori_buku(id) ON DELETE SET NULL,
    status VARCHAR(20) DEFAULT 'tersedia'
);

CREATE TABLE peminjaman (
    id SERIAL PRIMARY KEY,
    id_user INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    id_buku INT NOT NULL REFERENCES buku(id) ON DELETE RESTRICT,
    tanggal_pinjam DATE DEFAULT CURRENT_DATE,
    tanggal_jatuh_tempo DATE NOT NULL,
    status_pinjam VARCHAR(20) DEFAULT 'aktif'
);

CREATE TABLE pengembalian (
    id SERIAL PRIMARY KEY,
    id_peminjaman INT NOT NULL REFERENCES peminjaman(id) ON DELETE CASCADE,
    tanggal_kembali DATE DEFAULT CURRENT_DATE
);

CREATE OR REPLACE FUNCTION set_status_buku_dipinjam()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE buku
    SET status = 'dipinjam'
    WHERE id = NEW.id_buku;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_status_buku_dipinjam
AFTER INSERT ON peminjaman
FOR EACH ROW
EXECUTE FUNCTION set_status_buku_dipinjam();

CREATE OR REPLACE FUNCTION set_status_buku_dikembalikan()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE buku
    SET status = 'tersedia'
    WHERE id = (SELECT id_buku FROM peminjaman WHERE id = NEW.id_peminjaman);

    UPDATE peminjaman
    SET status_pinjam = 'selesai'
    WHERE id = NEW.id_peminjaman;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_status_buku_dikembalikan
AFTER INSERT ON pengembalian
FOR EACH ROW
EXECUTE FUNCTION set_status_buku_dikembalikan();

CREATE OR REPLACE VIEW view_riwayat_peminjaman AS
SELECT 
    p.id AS id_peminjaman,
	p.id_user,
    u.nama AS nama_user,
    b.judul AS judul_buku,
    p.tanggal_pinjam,
    p.tanggal_jatuh_tempo,
    pg.tanggal_kembali,
    p.status_pinjam
FROM peminjaman p
JOIN users u ON p.id_user = u.id
JOIN buku b ON p.id_buku = b.id
LEFT JOIN pengembalian pg ON p.id = pg.id_peminjaman;

ALTER TABLE users ADD CONSTRAINT chk_role_valid
CHECK (role_id > 0);

ALTER TABLE buku ADD CONSTRAINT chk_status_valid
CHECK (status IN ('tersedia', 'dipinjam'));

ALTER TABLE peminjaman ADD CONSTRAINT chk_status_pinjam_valid
CHECK (status_pinjam IN ('aktif', 'selesai', 'terlambat'));

select * from kategori_buku;
select * from buku;
select * from users;
select * from roles;
select * from peminjaman;
select * from pengembalian;

INSERT INTO roles (nama_role) VALUES ('admin');
INSERT INTO roles (nama_role) VALUES ('user');

SELECT * FROM users WHERE username = 'admin';

DROP VIEW IF EXISTS view_riwayat_peminjaman;

SELECT * FROM personal_access_tokens;

TRUNCATE TABLE users RESTART IDENTITY CASCADE;
TRUNCATE TABLE roles RESTART IDENTITY CASCADE;

DELETE FROM users;
