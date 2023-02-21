CREATE DATABASE CDN_BTL
GO
use CDN_BTL;
GO
CREATE TABLE tbl_HANGSX (
	sIDHang NVARCHAR(10) not null,
	sTenHang NVARCHAR (30) not null,
	sQuocGia NVARCHAR (30) not null,
	CONSTRAINT PK_HANGSX PRIMARY KEY (sIDHang)
);

CREATE TABLE tbl_NHAPP (
	sIDNPP NVARCHAR(10) not null,
	sTenNPP NVARCHAR(30) not null,
	sSDT NVARCHAR(12) not null,
	sDiaChi NVARCHAR(50) not null,
	CONSTRAINT PK_NHAPP PRIMARY KEY (sIDNPP)
);

CREATE TABLE tbl_SANPHAM (
	sIDSP NVARCHAR(10) NOT NULL,
	sIDHang NVARCHAR(10) not null,
	sIDNPP NVARCHAR (10) not null,
	sTenSeries NVARCHAR(30) not null,
	iBaoHanh int not null,
	sTenCPU NVARCHAR (30) not null,
	iDungLuongRAM int not null,
	sMauSac NVARCHAR(30) not null,
	sLoaiODia NVARCHAR (10) not null,
	iDungLuongDia int not null,
	iNamSX int not null,
	iGiaBan int not null,
	iTonKho int not null,
	CONSTRAINT PK_SP PRIMARY KEY (sIDSP),
	CONSTRAINT fk_sp_idHang	FOREIGN KEY (sIDHang) REFERENCES tbl_HANGSX (sIDHang),
	CONSTRAINT fk_sp_idNPP	FOREIGN KEY (sIDNPP) REFERENCES tbl_NHAPP (sIDNPP)
);
CREATE TABLE tbl_KHACHHANG (
	sIDKH NVARCHAR(10) not null,
	sTenKhach NVARCHAR(30) not null,
	sSDT NVARCHAR(12) not null,
	sDiaChi NVARCHAR(50) not null,
	sEmail NVARCHAR (50) not null,
	CONSTRAINT PK_KH PRIMARY KEY (sIDKH)
);

CREATE TABLE tbl_NHANVIEN (
	sIDNV NVARCHAR(10) not null,
	sTenNV NVARCHAR(30) not null, 
	dNgaySinh date not null,
	dNgayVaoLam date not null,
	sGioiTinh NVARCHAR(10) not null,
	sSDT NVARCHAR(12) not null, 
	sViTri NVARCHAR (30) not null,
	fHSL float not null,
	CONSTRAINT PK_NV PRIMARY KEY (sIDNV)
);

CREATE TABLE tbl_HOADONBAN (
	sIDHD NVARCHAR(10) not null, 
	sIDNV NVARCHAR(10) not null, 
	sIDKH NVARCHAR(10) not null, 
	dNgaylap date not null, 
	CONSTRAINT PK_HOADONBAN PRIMARY KEY (sIDHD),
	CONSTRAINT fk_hdb_idnv FOREIGN KEY (sIDNV) REFERENCES tbl_NHANVIEN (sIDNV),
	CONSTRAINT fk_hdb_idkh FOREIGN KEY (sIDKH) REFERENCES tbl_KHACHHANG (sIDKH)
);

CREATE TABLE tbl_DONNHAP (
	sIDDonNhap NVARCHAR(10) not null, 
	sIDNV NVARCHAR(10) not null, 
	dNgayNhap NVARCHAR(10) not null,
	CONSTRAINT PK_DONNHAP PRIMARY KEY (sIDDonNhap),
	CONSTRAINT fk_dn_idnv FOREIGN KEY (sIDNV) REFERENCES tbl_NHANVIEN (sIDNV)
);

CREATE TABLE tbl_PHIEUYCBH (
	sIDPYC NVARCHAR(10) not null, 
	sIDNV NVARCHAR(10) not null, 
	sIDKH NVARCHAR(10) not null, 
	dNgayYC date not null,
	CONSTRAINT PK_PHIEUYCBH PRIMARY KEY (sIDPYC),
	CONSTRAINT fk_pycbh_idnv FOREIGN KEY (sIDNV) REFERENCES tbl_NHANVIEN (sIDNV),
	CONSTRAINT fk_pycbh_idnpp FOREIGN KEY (sIDKH) REFERENCES tbl_KHACHHANG (sIDKH)
);


CREATE TABLE tbl_DONGHOADON (
	sIDHD NVARCHAR(10) not null, 
	sIDSP NVARCHAR(10) not null, 
	iSoLuongBan int not null, 
	iDonGiaBan int not null, 
	CONSTRAINT PK_DONGHOADON PRIMARY KEY (sIDHD,sIDSP),
	CONSTRAINT fk_dhd_hd FOREIGN KEY (sIDHD) REFERENCES tbl_HOADONBAN (sIDHD),
	CONSTRAINT fk_dhd_sp FOREIGN KEY (sIDSP) REFERENCES tbl_SANPHAM (sIDSP)
);
CREATE TABLE tbl_DONGDONNHAP (
	sIDDonNhap NVARCHAR(10) not null, 
	sIDSP NVARCHAR(10) not null, 
	iSoLuongNhap int not null, 
	iDonGiaNhap int not null,
	CONSTRAINT PK_DONGDONNHAP PRIMARY KEY (sIDDonNhap,sIDSP),
	CONSTRAINT fk_ddn_dn FOREIGN KEY (sIDDonNhap) REFERENCES tbl_DONNHAP (sIDDonNhap),
	CONSTRAINT fk_ddn_sp FOREIGN KEY (sIDSP) REFERENCES tbl_SANPHAM (sIDSP)
);


CREATE TABLE tbl_DONGYEUCAU (
	sIDPYC NVARCHAR(10) not null, 
	sIDSP NVARCHAR(10) not null, 
	sTinhTrangLoi  NVARCHAR(50) not null, 
	CONSTRAINT PK_DONGYEUCAU PRIMARY KEY (sIDPYC,sIDSP),
	CONSTRAINT fk_dpyc_pyc FOREIGN KEY (sIDPYC) REFERENCES tbl_PHIEUYCBH (sIDPYC),
	CONSTRAINT fk_dpyc_sp FOREIGN KEY (sIDSP) REFERENCES tbl_SANPHAM (sIDSP)
);

-- dữ liệu mẫu 
INSERT INTO tbl_HANGSX (sIDHang, sQuocGia, sTenHang)
VALUES	('hsx01',N'Đài Loan', 'Asus'),
		('hsx02',N'Mỹ', 'Dell'),
		('hsx03',N'Mỹ', 'HP'),
		('hsx04',N'Mỹ', 'EVOO'),
		('hsx05',N'Trung Quốc', 'Huawei'),
		('hsx06',N'Trung Quốc', 'Xiaomi'),
		('hsx07',N'Đài Loan', 'MSI'),
		('hsx08',N'Đài Loan', 'Gigabyte'),
		('hsx09',N'Đài Loan', 'Acer'),
		('hsx10',N'Trung Quốc', 'Lenovo'),
		('hsx11',N'Mỹ', 'Apple');
--delete from tbl_HANGSX where (1=1);
--Select * from tbl_HANGSX;

INSERT INTO tbl_NHAPP(sIDNPP, sTenNPP, sSDT, sDiaChi)
VALUES (N'npp01',N'Ninza','0237562208',N'Hà Nội'),
	('npp02',N'NOVA','039335856',N'HCM'),
	('npp03',N'Star','03757979',N'Cần Thơ'),
	('npp04',N'HACOM','038443008',N'Hà Nội'),
	('npp05',N'Gearvn','03813700',N'HCM'),
	('npp06',N'An Phát','039350865',N'Hà Nội'),
	('npp07',N'Phúc Anh','039454212',N'Đà Nẵng'),
	('npp08',N'Tân Phú','03822454',N'Hà Nội'),
	('npp09',N'Phú Cường','038288866',N'Hà Nội'),
	('npp010',N'Thanh Bình','039482635',N'Hà Nội');
--Select * from tbl_NHAPP;
--delete from tbl_NHAPP where (1=1);
-- chưa insert sản phẩm

INSERT INTO  tbl_SANPHAM(sIDSP,sIDHang,sIDNPP,sTenSeries,iBaoHanh,
				sTenCPU,iDungLuongRAM,sMauSac,sLoaiODia,iDungLuongDia,iNamSX,iGiaBan,iTonKho)
VALUES ('sp01','hsx01','npp01','Vivobook',24,'Intel Core I5',8,N'Đen','SSD NVME',512,2022,15000,0),
('sp02','hsx01','npp05','ROG Strix',24,'Intel Core I7',16,N'Đen','SSD NVME',512,2022,24000,0),
('sp03','hsx03','npp07','OMEN',12,'AMD Ryzen 7',8,N'Đen','SSD NVME',512,2021,27000,0),
('sp04','hsx02','npp03','XPS',36,'Intel Core I5',8,N'Bạc','SSD NVME',512,2022,30000,0),
('sp05','hsx02','npp03','Inspiron',24,'Intel Core I3',8,N'Bạc','HDD',500,2019,12000,0),
('sp06','hsx10','npp04','Ideapad',12,'AMD Ryzen 5',8,N'Bạc','SSD NVME',256,2020,17000,0),
('sp07','hsx10','npp04','Thinkpad X280',12,'Intel core i5',8,N'Bạc','SSD',256,2018,19000,0),
('sp08','hsx09','npp07','Swift',36,'Intel Core I5',8,N'Đen','HDD',500,2019,14000,0),
('sp09','hsx09','npp03','Trident',36,'Intel Core I7',16,N'Xám','SSD NVME',512,2021,31000,0),
('sp10','hsx05','npp09','Matebook',6,'AMD Ryzen 3',8,N'Xám','SSD NVME',256,2021,14000,0);


INSERT INTO tbl_KHACHHANG(sIDKH,sSDT, sTenKhach, sDiachi, sEmail)
VALUES	('kh01','0337666735',N'Bạc Công Bằng',N'Hà Nội','Congbang123@gmail.com'),
		('kh02','0338488327',N'Nguyễn Ðức Cường',N'Hà Nội','Duccuong1847@yahoo.com'),
		('kh03','0337735558',N'Nguyễn Hồng Minh',N'Bắc Ninh','Minhu2h@gmail.com'),
		('kh04','0338510957',N'Nguyễn Ðức Nhân',N'Phú Thọ','nhanwhjk@gmail.com'),
		('kh05','0339070648',N'Ngô Hải Vân',N'Hà Nội','kendrick.david@snake.com'),
		('kh06','0337365406',N'Hà Huệ Linh',N'Thanh Hóa','lucia.thornton@lobster.com'),
		('kh07','0339341918',N'Lê Trúc Ðào',N'Hà Nội','lina.frazier@bee.com'),
		('kh08','0338623489',N'Trần Trường Vinh',N'Bắc Giang','minh.yang@owl.com'),
		('kh09','0339438902',N'Khương Tuấn Anh',N'Hải Phòng','gay.fernandez@kitten.com'),
		('kh10','0338390311',N'Lý Dương Anh',N'Hưng Yên','romeo.slater@eagle.com');
select * from tbl_KHACHHANG;
--select * from tbl_SANPHAM;
INSERT into tbl_NHANVIEN (sIDNV, sTenNV, dNgaySinh, dNgayVaoLam, sGioiTinh, sSDT, sViTri, fHSL)
VALUES	('nv01',N'Phan Duy Hùng','1995-10-01','2018-04-19',N'Nam','0338265110',N'Bán hàng', 4.8),
		('nv02',N'Võ Văn Minh','1997-11-21','2020-01-15',N'Nam','0337175502',N'Bán hàng', 4.5),
		('nv03',N'Đào Ngọc Vân','1996-09-21','2019-05-25',N'Nữ','0366535141',N'Thu Ngân', 4.3),
		('nv04',N'Trần Nguyên Lộc','1994-10-21','2019-04-13',N'Nam','0362965041',N'Kỹ thuật viên', 5.0),
		('nv05',N'Phùng Xuân Nam','1996-07-22','2020-06-13',N'Nam','033822288',N'Kỹ thuật viên', 4.7),
		('nv06',N'Võ Việt Khôi','1998-09-06','2020-09-26',N'Nam','0338352361',N'Bán Hàng', 4.5),
		('nv07',N'Giang Tường Vy','1999-02-18','2021-09-26',N'Nữ','0337365262',N'Thu Ngân', 4.2),
		('nv08',N'Dư Bảo Ðịnh','1967-02-12','2019-01-26',N'Nam','0339692202',N'Bảo Vệ', 3.5),
		('nv09',N'Đinh Thành Trung','1966-06-08','2020-03-16',N'Nam','0336434504',N'Bảo Vệ', 3.4),
		('nv10',N'Vũ Hoàng Cúc','1999-03-28','2021-10-06',N'Nữ','0338920600',N'Thủ Kho', 4.2);
INSERT into tbl_NHANVIEN (sIDNV, sTenNV, dNgaySinh, dNgayVaoLam, sGioiTinh, sSDT, sViTri, fHSL)
VALUES ('nv11',N'Lưu Xuân Bảo','1993-03-28','2017-10-06',N'Nữ','3860111',N'Thủ Kho', 4.8);

--select * from tbl_Nhanvien;
	
INSERT INTO tbl_HOADONBAN (sIDHD, sIDNV, sIDKH, dNgaylap) 
VALUES	('hd01','nv03','kh03','2019-05-29'),
		('hd02','nv03','kh02','2019-12-21'),
		('hd03','nv03','kh01','2020-08-22'),
		('hd04','nv03','kh04','2020-02-23'),
		('hd05','nv03','kh06','2020-08-21'),
		('hd06','nv03','kh08','2021-11-12'),
		('hd07','nv03','kh05','2021-03-01'),
		('hd08','nv03','kh07','2021-01-04'),
		('hd09','nv07','kh09','2022-08-14'),
		('hd10','nv07','kh10','2022-05-17');

--select *from tbl_HOADONBAN;

INSERT INTO tbl_DONNHAP (sIDDonNhap, sIDNV, dNgayNhap)
VALUES	('dn01','nv11','2019-04-21'),
		('dn02','nv11','2019-05-15'),
		('dn03','nv11','2019-06-14'),
		('dn04','nv11','2020-07-05'),
		('dn05','nv11','2020-04-30'),
		('dn06','nv11','2021-04-12'),
		('dn07','nv10','2021-07-21'),
		('dn08','nv10','2022-04-20'),
		('dn09','nv10','2022-04-24'),
		('dn10','nv10','2022-04-29');

INSERT INTO tbl_PHIEUYCBH (sIDPYC, sIDNV, sIDKH, dNgayYC)
VALUES	('pyc01','nv04','kh03','2019-10-27'),
		('pyc02','nv04','kh02','2019-12-28'),
		('pyc03','nv04','kh01','2020-12-20'),
		('pyc04','nv04','kh04','2020-12-20'),
		('pyc05','nv04','kh06','2021-12-20'),
		('pyc06','nv05','kh08','2021-12-20'),
		('pyc07','nv05','kh05','2021-12-20'),
		('pyc08','nv05','kh07','2022-12-20'),
		('pyc09','nv05','kh09','2022-12-20'),
		('pyc10','nv05','kh10','2022-12-20');


INSERT INTO tbl_DONGDONNHAP (sIDDonNhap, sIDSP, iSoLuongNhap, iDonGiaNhap)
VALUES	('dn01','sp05',15,10000),
		('dn01','sp07',10,17000),
		('dn02','sp08',10,12000),
		('dn03','sp05',30,11000),
		('dn04','sp06',20,15000),
		('dn05','sp05',20,10000),
		('dn06','sp03',10,25000),
		('dn06','sp10',10,25000),
		('dn07','sp09',10,28000),
		('dn08','sp01',30,14000),
		('dn09','sp02',10,21000),
		('dn10','sp04',5,28000);


INSERT INTO tbl_DONGHOADON(sIDHD,sIDSP,iSoLuongBan,iDonGiaBan)
VALUES		('hd01','sp05',1,12000),
			('hd02','sp08',2,14000),
			('hd03','sp06',1,17000),
			('hd04','sp05',2,12000),
			('hd05','sp10',1,14000),
			('hd06','sp09',1,31000),
			('hd07','sp07',2,19000),
			('hd08','sp05',1,12000),
			('hd09','sp04',1,30000),
			('hd09','sp02',1,24000),
			('hd10','sp01',1,12000),
			('hd10','sp03',1,27000);
INSERT INTO tbl_DONGYEUCAU (sIDPYC,sIDSP, sTinhTrangLoi)
VALUES ('pyc01','sp05',N'Gãy bản lề'),
		('pyc02','sp08',N'Liệt phím'),
		('pyc03','sp06',N'Không lên nguồn'),
		('pyc04','sp05',N'Máy chạy chậm'),
		('pyc05','sp10',N'Màn hình tối'),
		('pyc06','sp09',N'Máy nóng'),
		('pyc07','sp07',N'Đổ nước lên phím, máy không lên'),
		('pyc08','sp05',N'Vỡ màn hình'),
		('pyc09','sp04',N'Mất touchpad'),
		('pyc10','sp01',N'Hỏng loa ngoài');