-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Waktu pembuatan: 09 Jun 2023 pada 17.46
-- Versi server: 8.0.30
-- Versi PHP: 8.1.10

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `toko_buah`
--

DELIMITER $$
--
-- Prosedur
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_pembelian` ()   UPDATE pembelian
INNER JOIN penjualan
SET pembelian.status = 1
WHERE pembelian.subtotal = penjualan.subtotal$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_penjualan` ()   UPDATE penjualan
INNER JOIN pembelian
SET penjualan.status = 1
WHERE pembelian.subtotal = penjualan.subtotal$$

--
-- Fungsi
--
CREATE DEFINER=`root`@`localhost` FUNCTION `hitung_omset` (`return_tanggal` DATE) RETURNS VARCHAR(255) CHARSET utf8mb4 DETERMINISTIC BEGIN
DECLARE url varchar(255);
SELECT SUM(subtotal) INTO url FROM penjualan WHERE tanggal = return_tanggal;
RETURN url;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `barang`
--

CREATE TABLE `barang` (
  `barang_id` int NOT NULL,
  `nama_barang` varchar(255) NOT NULL,
  `kode_barang` int NOT NULL,
  `satuan` int NOT NULL,
  `stok` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data untuk tabel `barang`
--

INSERT INTO `barang` (`barang_id`, `nama_barang`, `kode_barang`, `satuan`, `stok`) VALUES
(1, 'remote', 1, 1, 4);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `history`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `history` (
`tanggal` date
,`kode_barang` int
,`nama_barang` varchar(255)
,`masuk` bigint
,`keluar` decimal(32,0)
,`total` int
);

-- --------------------------------------------------------

--
-- Struktur dari tabel `pelunasan`
--

CREATE TABLE `pelunasan` (
  `pelunasan_id` int NOT NULL,
  `pembelian_id` int NOT NULL,
  `penjualan_id` int NOT NULL,
  `subtotal` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data untuk tabel `pelunasan`
--

INSERT INTO `pelunasan` (`pelunasan_id`, `pembelian_id`, `penjualan_id`, `subtotal`) VALUES
(1, 5, 2, 123),
(4, 5, 3, 12000);

--
-- Trigger `pelunasan`
--
DELIMITER $$
CREATE TRIGGER `delete_pelunasan_table` AFTER DELETE ON `pelunasan` FOR EACH ROW BEGIN
UPDATE penjualan
SET penjualan.status = 0
WHERE penjualan.penjualan_id = OLD.penjualan_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `insert_pelunasan_table` AFTER INSERT ON `pelunasan` FOR EACH ROW BEGIN
UPDATE penjualan
SET penjualan.status = 1
WHERE penjualan.penjualan_id = NEW.penjualan_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_pelunasan_table` AFTER UPDATE ON `pelunasan` FOR EACH ROW BEGIN
UPDATE penjualan
SET penjualan.status = 1
WHERE penjualan.penjualan_id = NEW.penjualan_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `pembelian`
--

CREATE TABLE `pembelian` (
  `penjualan_id` int NOT NULL,
  `tanggal` date NOT NULL,
  `nomer_jual` int NOT NULL,
  `barang_id` int NOT NULL,
  `jumlah` int NOT NULL,
  `satuan` int NOT NULL,
  `harga` int NOT NULL,
  `diskon` int NOT NULL,
  `subtotal` int NOT NULL,
  `status` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data untuk tabel `pembelian`
--

INSERT INTO `pembelian` (`penjualan_id`, `tanggal`, `nomer_jual`, `barang_id`, `jumlah`, `satuan`, `harga`, `diskon`, `subtotal`, `status`) VALUES
(5, '2023-06-09', 1, 1, 2, 1, 1, 1, 123, 1);

--
-- Trigger `pembelian`
--
DELIMITER $$
CREATE TRIGGER `delete_pelunasan` AFTER DELETE ON `pembelian` FOR EACH ROW UPDATE penjualan
        SET status = 0
        WHERE subtotal = penjualan.subtotal
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `delete_pembelian` AFTER DELETE ON `pembelian` FOR EACH ROW UPDATE barang SET barang.stok = 
barang.stok - OLD.jumlah
WHERE barang.barang_id = OLD.barang_id
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `insert_pelunasan` AFTER INSERT ON `pembelian` FOR EACH ROW BEGIN
UPDATE penjualan
SET penjualan.status = 1
WHERE NEW.subtotal = penjualan.subtotal;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `insert_pembelian` AFTER INSERT ON `pembelian` FOR EACH ROW BEGIN
UPDATE barang 
SET barang.stok = barang.stok + NEW.jumlah
WHERE barang.barang_id = NEW.barang_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_pelunasan` AFTER UPDATE ON `pembelian` FOR EACH ROW BEGIN
    UPDATE penjualan
        SET status = 1
        WHERE NEW.subtotal = penjualan.subtotal;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_pembelian` AFTER UPDATE ON `pembelian` FOR EACH ROW UPDATE barang SET barang.stok = 
(barang.stok - OLD.jumlah) + NEW.jumlah
WHERE barang.barang_id = NEW.barang_id
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `penjualan`
--

CREATE TABLE `penjualan` (
  `penjualan_id` int NOT NULL,
  `tanggal` date NOT NULL,
  `nomer_jual` int NOT NULL,
  `barang_id` int NOT NULL,
  `jumlah` int NOT NULL,
  `satuan` int NOT NULL,
  `harga` int NOT NULL,
  `diskon` int NOT NULL,
  `subtotal` int NOT NULL,
  `status` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data untuk tabel `penjualan`
--

INSERT INTO `penjualan` (`penjualan_id`, `tanggal`, `nomer_jual`, `barang_id`, `jumlah`, `satuan`, `harga`, `diskon`, `subtotal`, `status`) VALUES
(2, '2023-06-09', 1, 1, 2, 1, 1, 1, 123, 1),
(3, '2023-06-09', 1, 1, 2, 1, 1, 1, 111, 0);

--
-- Trigger `penjualan`
--
DELIMITER $$
CREATE TRIGGER `delete_penjualan` AFTER DELETE ON `penjualan` FOR EACH ROW UPDATE barang SET barang.stok = 
barang.stok + OLD.jumlah
WHERE barang.barang_id = OLD.barang_id
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `penjualan_insert` AFTER INSERT ON `penjualan` FOR EACH ROW BEGIN
UPDATE barang 
SET barang.stok = barang.stok - NEW.jumlah
WHERE barang.barang_id = NEW.barang_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_penjualan` AFTER UPDATE ON `penjualan` FOR EACH ROW UPDATE barang SET barang.stok = 
(barang.stok + OLD.jumlah) - NEW.jumlah
WHERE barang.barang_id = NEW.barang_id
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur untuk view `history`
--
DROP TABLE IF EXISTS `history`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `history`  AS SELECT `penjualan`.`tanggal` AS `tanggal`, `barang`.`kode_barang` AS `kode_barang`, `barang`.`nama_barang` AS `nama_barang`, count(`pembelian`.`jumlah`) AS `masuk`, sum(`penjualan`.`jumlah`) AS `keluar`, `pelunasan`.`subtotal` AS `total` FROM (((`penjualan` join `pembelian`) join `pelunasan`) join `barang`) GROUP BY `barang`.`barang_id`, `penjualan`.`tanggal`, `pelunasan`.`pelunasan_id` ;

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `barang`
--
ALTER TABLE `barang`
  ADD PRIMARY KEY (`barang_id`);

--
-- Indeks untuk tabel `pelunasan`
--
ALTER TABLE `pelunasan`
  ADD PRIMARY KEY (`pelunasan_id`),
  ADD KEY `pembelian_id` (`pembelian_id`,`penjualan_id`),
  ADD KEY `penjualan_id` (`penjualan_id`);

--
-- Indeks untuk tabel `pembelian`
--
ALTER TABLE `pembelian`
  ADD PRIMARY KEY (`penjualan_id`),
  ADD KEY `barang_id` (`barang_id`);

--
-- Indeks untuk tabel `penjualan`
--
ALTER TABLE `penjualan`
  ADD PRIMARY KEY (`penjualan_id`),
  ADD KEY `barang_id` (`barang_id`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `barang`
--
ALTER TABLE `barang`
  MODIFY `barang_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT untuk tabel `pelunasan`
--
ALTER TABLE `pelunasan`
  MODIFY `pelunasan_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `pembelian`
--
ALTER TABLE `pembelian`
  MODIFY `penjualan_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT untuk tabel `penjualan`
--
ALTER TABLE `penjualan`
  MODIFY `penjualan_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `pelunasan`
--
ALTER TABLE `pelunasan`
  ADD CONSTRAINT `pelunasan_ibfk_1` FOREIGN KEY (`penjualan_id`) REFERENCES `penjualan` (`penjualan_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `pelunasan_ibfk_2` FOREIGN KEY (`pembelian_id`) REFERENCES `pembelian` (`penjualan_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `pembelian`
--
ALTER TABLE `pembelian`
  ADD CONSTRAINT `pembelian_ibfk_1` FOREIGN KEY (`barang_id`) REFERENCES `barang` (`barang_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `penjualan`
--
ALTER TABLE `penjualan`
  ADD CONSTRAINT `penjualan_ibfk_1` FOREIGN KEY (`barang_id`) REFERENCES `barang` (`barang_id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
