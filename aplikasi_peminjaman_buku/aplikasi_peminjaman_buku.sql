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

ALTER TABLE users ADD COLUMN foto VARCHAR(255) NULL;

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


	/Modifikasi db/
	-- 1. Tambah kolom stok
ALTER TABLE buku
ALTER COLUMN stok_tersedia DROP DEFAULT;
ALTER TABLE buku
ALTER COLUMN stok_tersedia SET NOT NULL;

UPDATE buku
SET stok_tersedia = stok_total
WHERE stok_tersedia < stok_total
AND id NOT IN (
    SELECT DISTINCT id_buku
    FROM peminjaman
    WHERE status_pinjam IN (
        'dipinjam',
        'menunggu_pengembalian'
    )
);

ALTER TABLE buku
ADD CONSTRAINT chk_stok_valid
CHECK (
    stok_tersedia >= 0
    AND stok_tersedia <= stok_total
);

SELECT id, judul, stok_total, stok_tersedia
FROM buku;

-- 2. Ubah cek status (opsional) — hapus constraint chk_status_valid karena kita pakai stok
ALTER TABLE buku DROP CONSTRAINT IF EXISTS chk_status_valid;

-- 3. Tambah status baru di peminjaman: 'pending' saat request dibuat
ALTER TABLE peminjaman ALTER COLUMN status_pinjam TYPE VARCHAR(20);
-- (constraint baru)
ALTER TABLE peminjaman DROP CONSTRAINT IF EXISTS chk_status_pinjam_valid;
ALTER TABLE peminjaman ADD CONSTRAINT chk_status_pinjam_valid
CHECK (status_pinjam IN ('pending', 'aktif', 'selesai', 'terlambat', 'ditolak'));

-- 4. Hapus/modifikasi trigger lama yang meng-set status buku 'dipinjam' / 'tersedia'
DROP TRIGGER IF EXISTS trg_set_status_buku_dipinjam ON peminjaman;
DROP FUNCTION IF EXISTS set_status_buku_dipinjam();

DROP TRIGGER IF EXISTS trg_set_status_buku_dikembalikan ON pengembalian;
DROP FUNCTION IF EXISTS set_status_buku_dikembalikan();

-- 5. (Opsional) Index untuk pencarian cepat
CREATE INDEX IF NOT EXISTS idx_buku_judul ON buku(judul);

ALTER TABLE users ADD COLUMN nim VARCHAR(30);

ALTER TABLE users 
ALTER COLUMN nim SET NOT NULL;

ALTER TABLE users 
ALTER COLUMN nim DROP NOT NULL;

ALTER TABLE users 
DROP CONSTRAINT users_nim_unique;

ALTER TABLE users 
ADD CONSTRAINT users_nim_unique UNIQUE(nim);

ALTER TABLE users 
ADD COLUMN prodi VARCHAR(100) NULL;

ALTER TABLE peminjaman 
ALTER COLUMN status_pinjam SET DEFAULT 'pending';

ALTER TABLE peminjaman DROP CONSTRAINT IF EXISTS chk_status_pinjam_valid;

ALTER TABLE peminjaman
ADD CONSTRAINT chk_status_pinjam_valid 
CHECK (status_pinjam IN ('pending', 'aktif', 'selesai', 'terlambat', 'ditolak'));

UPDATE peminjaman 
SET status_pinjam = 'pending'
WHERE status_pinjam NOT IN ('aktif', 'selesai', 'terlambat', 'ditolak');

ALTER TABLE buku 
ALTER COLUMN stok_total SET NOT NULL,
ALTER COLUMN stok_tersedia SET NOT NULL;

DROP TRIGGER IF EXISTS trg_set_status_buku_dipinjam ON peminjaman;
DROP FUNCTION IF EXISTS set_status_buku_dipinjam();

DROP TRIGGER IF EXISTS trg_set_status_buku_dikembalikan ON pengembalian;
DROP FUNCTION IF EXISTS set_status_buku_dikembalikan();

ALTER TABLE users
ADD COLUMN angkatan VARCHAR(10);

ALTER TABLE peminjaman
ALTER COLUMN tanggal_pinjam DROP DEFAULT;

SELECT * FROM view_riwayat_peminjaman;

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
JOIN buku b ON p.id_buku = b.id;

ALTER TABLE peminjaman ADD COLUMN tanggal_pengembalian_dipilih DATE NULL;


ALTER TABLE peminjaman 
DROP CONSTRAINT chk_status_pinjam_valid;

ALTER TABLE peminjaman 
ADD CONSTRAINT chk_status_pinjam_valid CHECK (
    status_pinjam IN (
        'dipinjam',
        'menunggu',
        'dikembalikan',
        'pengajuan_kembali'
    )
);


SELECT *
FROM peminjaman
WHERE status_pinjam NOT IN (
    'dipinjam',
    'menunggu_persetujuan',
    'pengajuan_kembali',
    'dikembalikan'
);


ALTER TABLE peminjaman 
DROP CONSTRAINT IF EXISTS chk_status_pinjam_valid;

ALTER TABLE peminjaman 
ADD CONSTRAINT chk_status_pinjam_valid CHECK (
    status_pinjam IN (
        'dipinjam',
        'menunggu_persetujuan',
        'pengajuan_kembali',
        'dikembalikan'
    )
);
SELECT DISTINCT status_pinjam FROM peminjaman;

UPDATE peminjaman
SET status_pinjam = 'menunggu_persetujuan'
WHERE status_pinjam = 'pending';

UPDATE peminjaman
SET status_pinjam = 'dipinjam'
WHERE status_pinjam = 'aktif';

SELECT DISTINCT status_pinjam FROM peminjaman;

ALTER TABLE peminjaman 
ADD CONSTRAINT chk_status_pinjam_valid CHECK (
    status_pinjam IN (
        'dipinjam',
        'menunggu_persetujuan',
        'pengajuan_kembali',
        'menunggu_pengembalian',
        'dikembalikan'
    )
);


SELECT conname
FROM pg_constraint
WHERE conname LIKE '%status_pinjam%';

UPDATE peminjaman SET status_pinjam = 'menunggu_persetujuan' WHERE status_pinjam = 'pending';
UPDATE peminjaman SET status_pinjam = 'dipinjam' WHERE status_pinjam = 'aktif';
UPDATE peminjaman SET status_pinjam = 'dikembalikan' WHERE status_pinjam = 'selesai';
UPDATE peminjaman
SET status_pinjam = 'pengajuan_kembali'
WHERE status_pinjam = 'diajukan';

DELETE FROM peminjaman WHERE status_pinjam = 'ditolak'; -- kalau tidak dibutuhkan

SELECT id, status_pinjam FROM peminjaman WHERE id = 2;

DESCRIBE peminjaman;

SELECT
  p.id,
  p.tanggal_pinjam,
  p.tanggal_jatuh_tempo,
  p.status_pinjam,
  pg.tanggal_kembali
FROM peminjaman p
JOIN pengembalian pg ON pg.id_peminjaman = p.id
WHERE p.status_pinjam = 'dikembalikan';

SELECT id, status_pinjam FROM peminjaman;

SELECT * FROM pengembalian;

SELECT p.id AS id_peminjaman,
       p.status_pinjam,
       g.tanggal_kembali
FROM peminjaman p
JOIN pengembalian g 
    ON g.id_peminjaman = p.id;

SELECT * FROM migrations ORDER BY batch, migration;

INSERT INTO migrations (migration, batch) 
VALUES ('2025_12_12_012132_add_stok_tersedia_to_buku_table', 3);

ALTER TABLE peminjaman 
MODIFY status_pinjam ENUM(
  'menunggu_persetujuan',
  'dipinjam',
  'pengajuan_kembali',
  'dikembalikan',
  'ditolak',
  'dibatalkan'
) NOT NULL;