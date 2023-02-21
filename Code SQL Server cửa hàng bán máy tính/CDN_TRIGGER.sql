--1.Không sửa được giá sản phẩm đã bán rồi trong dòng hóa đơn
--2.TẠO TRIGGER THÔNG BÁO KHI 1 SP ĐƯỢC THÊM 
---2.1 KHI 1 sp ĐC THÊM NẾU CÓ R BÁO LỖI, K CÓ THÌ BÁO THÀNH CÔNG:
--(LỖI vì nếu trùng khóa key thì sql báo trc trigger - this should used in proc)
--3.Trigger không cho phép sửa mã sản phẩm
--4 Trigger ngày lập hóa đơn bán của nhân viên phải sau ngày vào làm
--5 trigger ngày lập đơn nhập hàng phải sau ngày vào làm
--6.(khi thêm, sửa,xóa số lượng bán bảng donghoadon thì số lượng trên bảng SP cx cập nhật theo; số lượng bán ra k > số lg tồn kho
--7.trigger khi thêm 1 đơn hàng trong dòng đơn nhập, số lượng trong masp tg ứng tự động tăng
--*7.1 trigger khi xóa 1 đơn hàng trong dòng đơn nhập, số lượng trong masp tg ứng KHÔNG tự động giảm theo( đúng nhưng bỏ)
--7.2 trigger khi cập nhật số lượng trong dòng đơn nhập, số lượng trong masp tg ứng cập nhật theo
--8.TRIGGER khi xóa 1 mã hsx thì các sp của hsx đó cũng xóa theo( đang fix)
--8.1 PROC khi xóa 1 mã hsx thì các sp của hsx đó cũng xóa theo
--9. trigger hiển thị tổng nv nam, nữ sau khi thêm nhân viên
--10 Trigger khi thêm nhân viên tuổi nhân viên phải trên 18 tuổi
--11 GIỚI TÍNH GIẢNG VIÊN CHỈ ĐƯỢC LÀ NAM HOẶC NỮ

--1.Không sửa được giá sản phẩm đã bán rồi trong dòng hóa đơn
ALTER TRIGGER TRIKTHAYDOIGIASPDABAN
ON tbl_DONGHOADON
FOR UPDATE
AS
	BEGIN
		IF UPDATE(iDONGIABAN)
			PRINT('!Khong sua duoc gia san pham da ban roi')
			ROLLBACK TRAN
	END
UPDATE tbl_DONGHOADON
SET iDonGiaBan = 342340
WHERE sIDHD = 'HD01'
AND sIDSP = 'SP07'
GO

--2.TẠO TRIGGER THÔNG BÁO KHI 1 SP ĐƯỢC THÊM 
ALTER TRIGGER TRIGTHEMSP
ON tbl_SANPHAM
FOR INSERT 
AS 
BEGIN
	  DECLARE @MASP NVARCHAR(20)
	  SELECT @MASP=sIDSP FROM INSERTED
	  PRINT('THEM THANH CONG SAN PHAM CO MA SP: '+@MASP+ N' VAO BANG')	 
END
INSERT INTO tbl_SANPHAM 
VALUES('sp01100','hsx03','npp04','Elitebook',24,'Intel Core I5',8,N'Đen','SSD NVME',512,2020,30000,0)

GO

---2.1 KHI 1 sp ĐC THÊM NẾU CÓ R BÁO LỖI, K CÓ THÌ BÁO THÀNH CÔNG:
--(LỖI vì nếu trùng khóa key thì sql báo trc trigger - this should used in proc)
DROP TRIGGER TRIGTHEMSP2
CREATE TRIGGER TRIGTHEMSP2
ON tbl_SANPHAM
FOR INSERT 
AS 
BEGIN
	  DECLARE @MASP NVARCHAR(20)
	  SELECT @MASP=sIDSP FROM INSERTED
	  IF EXISTS ( SELECT sIDSP FROM tbl_SANPHAM WHERE sIDSP=@MASP)
		BEGIN 
			Raiserror('MA SAN PHAM DA CO, VUI LÒNG NHẬP LẠI',16,10)
			ROLLBACK TRAN
		END
	  ELSE
		BEGIN
			PRINT('THEM THANH CONG SAN PHAM CO MA SP: '+@MASP+ N' VAO BANG')	 
		END
END
INSERT INTO tbl_SANPHAM 
VALUES('sp01100','hsx03','npp04','Elitebook',24,'Intel Core I5',8,N'Đen','SSD NVME',512,2020,30000,0)

delete from tbl_SANPHAM where sIDSP = 'sp11'
GO

--3.Trigger không cho phép sửa mã sản phẩm
CREATE TRIGGER TrigKSuaMaSp
ON tbl_SANPHAM
FOR UPDATE
As
BEGIN
	If UPDATE(sIDSP)
		BEGIN
			PRINT N'Không thể thay đổi mã sản phẩm'
				ROLLBACK TRAN 
		END
END
GO
UPDATE tbl_SANPHAM
SET sIDSP = 'SP0193243'
WHERE iGiaBan = 1233454

delete from tbl_SANPHAM where sIDSP = 'SP0193243'

INSERT INTO tbl_SANPHAM 
VALUES('sp01100','hsx03','npp04','Elitebook',24,'Intel Core I5',8,N'Đen','SSD NVME',512,2020,30000,0)

delete from tbl_SANPHAM where sIDSP = 'sp11'
GO

--4 Trigger ngày lập hóa đơn bán của nhân viên phải sau ngày vào làm
CREATE TRIGGER CHECK_HOADONBANSAUNGAYVAOLAM
ON tbl_HOADONBAN
FOR UPDATE,INSERT
AS
    IF UPDATE(dNgaylap) --Kiểm tra việc cập nhật trên cột
    BEGIN
		DECLARE @dNgaylap SMALLDATETIME, @dNgayVaoLam SMALLDATETIME
		SET @dNgaylap=(SELECT dNgaylap FROM INSERTED)
		SET @dNgayVaoLam=(SELECT dNgayVaoLam FROM tbl_NHANVIEN A,INSERTED B WHERE A.sIDNV=B.sIDNV)
		IF(@dNgaylap<@dNgayVaoLam)
        BEGIN
			PRINT 'Ngay lap hoa don phai sau ngay lam '
			ROLLBACK TRAN 
			END
    END
--kiểm tra
INSERT INTO tbl_HOADONBAN (sIDHD, sIDNV, sIDKH, dNgaylap) 
VALUES	('hd11','nv03','kh03','2017-05-29');
go
--5 trigger ngày lập đơn nhập hàng phải sau ngày vào làm
CREATE TRIGGER CHECK_NGAYNV_NGAYNHAPHANG
ON tbl_DONNHAP
FOR UPDATE,INSERT
AS
    IF UPDATE(dNgayNhap) --Kiểm tra việc cập nhật trên cột
    BEGIN
		DECLARE @dNgayNhap SMALLDATETIME, @dNgayVaoLam SMALLDATETIME--dạng YYYY-MM-DD
		SET @dNgayNhap=(SELECT dNgayNhap FROM INSERTED)
		SET @dNgayVaoLam=(SELECT dNgayVaoLam FROM tbl_NHANVIEN A,INSERTED B WHERE A.sIDNV=B.sIDNV)
		IF(@dNgayNhap<@dNgayVaoLam)
        BEGIN
			PRINT 'Ngay nhap don hang phai sau ngay lam '
			ROLLBACK TRAN -- Câu lệnh quay lui khi thực hiện biến cố không thành công
			END
	END
--ktra
INSERT INTO tbl_DONNHAP (sIDDonNhap, sIDNV, dNgayNhap)
VALUES	('dn11','nv11','2016-04-21');
GO

--6.(khi thêm, sửa,xóa số lượng bán bảng donghoadon thì số lượng trên bảng SP cx cập nhật theo; số lượng bán ra k > số lg tồn kho
DROP TRIGGER Trg_DONGHOADON
ALTER TRIGGER Trg_DONGHOADON
ON tbl_DONGHOADON -- bảng bị tác động
FOR INSERT, update , delete
as
	begin
		Declare @sIDSP nvarchar(10),
		@iSoLuongBanInsert int ,
		@iSoLuongBanDelete int,
		@iSoLuongco int
		select @iSoLuongBanDelete = 0--vì insert thì delete = 0 và ngc lại
		select @iSoLuongBanInsert = 0

		SELECT @sIDSP = sIDSP, @iSoLuongBanInsert = iSoLuongBan 
		FROM inserted
		SELECT  @sIDSP = sIDSP, @iSoLuongBanDelete = iSoLuongBan--bị trùng sIDSP
		FROM deleted

		select @iSoLuongco = iTonKho + @iSoLuongBanDelete from tbl_SANPHAM where sIDSP = @sIDSP
		if(@iSoLuongco >= @iSoLuongBanInsert)
			begin
			UPDATE tbl_SANPHAM -- bảng bị tác động theo
			SET iTonKho = iTonKho - @iSoLuongBanInsert 
			WHERE sIDSP = @sIDSP

		
			UPDATE tbl_SANPHAM
			SET iTonKho = iTonKho + @iSoLuongBanDelete
			WHERE sIDSP = @sIDSP
			end
		else
			begin
				print(N'Số lượng bán vượt quá số lượng có');
				rollback transaction;
				
			end
	end
INSERT INTO tbl_DONGHOADON(sIDHD,sIDSP,iSoLuongBan,iDonGiaBan)
VALUES('hd14','sp07',100,15000)

delete from tbl_DONGHOADON
where sIDHD = 'hd14'

update tbl_DONGHOADON set iSoLuongBan = 8
where sIDHD = 'hd14' and sIDSP = 'sp07';
GO

--7.trigger khi thêm 1 đơn hàng trong dòng đơn nhập, số lượng trong masp tg ứng tự động tăng
ALTER TRIGGER SPTUDONGTHEM
ON TBL_DONGDONNHAP
FOR INSERT
AS
BEGIN
	DECLARE @SLNHAP INT, @MASP NVARCHAR(10)
	SELECT @SLNHAP = iSoLuongNhap, @MASP = sIDSP FROM inserted
	BEGIN
	UPDATE tbl_SANPHAM
	SET iTonKho = iTonKho + @SLNHAP
	WHERE sIDSP = @MASP
	END
END
INSERT INTO tbl_DONGDONNHAP VALUES('DN11', 'SP04', 10, 30000)
GO
--*7.1 trigger khi xóa 1 đơn hàng trong dòng đơn nhập, số lượng trong masp tg ứng KHÔNG tự động giảm theo( đúng nhưng bỏ)
DROP TRIGGER TUDONGGIAM
CREATE TRIGGER TUDONGGIAM
ON TBL_DONGDONNHAP
FOR DELETE
AS
BEGIN
	DECLARE @SLDONNHAP INT, @MASP NVARCHAR(10)
	SELECT @SLDONNHAP = iSoLuongNhap, @MASP = sIDSP FROM deleted
	BEGIN
		UPDATE tbl_SANPHAM
		SET iTonKho = iTonKho - @SLDONNHAP
		WHERE sIDSP = @MASP
	END
END
	DELETE FROM tbl_DONGDONNHAP
	WHERE sIDSP = 'SP04' AND sIDDonNhap = 'DN11'
GO


--7.2 trigger khi cập nhật số lượng trong dòng đơn nhập, số lượng trong masp tg ứng cập nhật theo
ALTER TRIGGER TUDONGCAPNHAT
ON TBL_DONGDONNHAP
FOR UPDATE
AS
BEGIN
	DECLARE @MASP NVARCHAR(10),
			@SL_OLD INT,
			@SL_NEW INT
		SELECT @SL_OLD = 0, @SL_OLD = 0--k cần
	SELECT @MASP = sIDSP, @SL_OLD = iSoLuongNhap FROM deleted--?
	SELECT @MASP = sIDSP, @SL_NEW = iSoLuongNhap FROM inserted
	BEGIN
	UPDATE tbl_SANPHAM
	SET iTonKho = iTonKho + @SL_NEW - @SL_OLD
	WHERE sIDSP = @MASP
	END
END
INSERT INTO tbl_DONGDONNHAP VALUES('DN11', 'SP05', 10, 30000)
DELETE FROM tbl_DONGDONNHAP WHERE sIDDonNhap = 'DN11'-- HÌNH NHƯ K ĐC XÓA
GO

--8.TRIGGER khi xóa 1 mã hsx thì các sp của hsx đó cũng xóa theo( đang fix)
CREATE TRIGGER XOAHANGTHISPCUNGXOATHEO
ON TBL_HANGSX
INSTEAD OF DELETE--CHỈ TÁC ĐỘNG LÊN INSERTED, DELETED THÔI CHỨ K TỚI CSDL
AS
BEGIN
	DECLARE @MASP NVARCHAR(20), @MAHANG NVARCHAR(10)
	SELECT @MAHANG = sIDHang FROM deleted
	BEGIN
		DELETE FROM tbl_DONGDONNHAP WHERE sIDSP IN (SELECT sIDSP FROM tbl_SANPHAM WHERE sIDHang = @MAHANG)
		DELETE FROM tbl_DONGHOADON WHERE sIDSP IN (SELECT sIDSP FROM tbl_SANPHAM WHERE sIDHang = @MAHANG)
		DELETE FROM tbl_SANPHAM WHERE sIDHang = @MAHANG
		DELETE FROM tbl_HANGSX WHERE sIDHang = @MAHANG
	END
END
DELETE FROM tbl_HANGSX WHERE sIDHang = 'HSXTHU'

INSERT INTO tbl_DONGDONNHAP VALUES('DNTHU', 'SPTHU', 10, 30000)
INSERT INTO tbl_DONGHOADON(sIDHD,sIDSP,iSoLuongBan,iDonGiaBan) VALUES('HDTHU','SPTHU',1,15000)
INSERT INTO tbl_SANPHAM VALUES('SPTHU','HSXTHU','npp05','Elitebook',24,'Intel Core I5',8,N'Đen','SSD NVME',512,2020,30000,0)
INSERT INTO tbl_HANGSX VALUES('HSXTHU','THU','THU')
GO

--8.1 PROC khi xóa 1 mã hsx thì các sp của hsx đó cũng xóa theo
ALTER PROC PRO_XOAHANGSPXOATHEO
@MAHANG NVARCHAR(10)
AS
BEGIN
		DELETE FROM tbl_DONGDONNHAP WHERE sIDSP IN (SELECT sIDSP FROM tbl_SANPHAM WHERE sIDHang = @MAHANG)
		DELETE FROM tbl_DONGHOADON WHERE sIDSP IN (SELECT sIDSP FROM tbl_SANPHAM WHERE sIDHang = @MAHANG)
		DELETE FROM tbl_SANPHAM WHERE sIDHang = @MAHANG
		DELETE FROM tbl_HANGSX WHERE sIDHang = @MAHANG
END
EXEC PRO_XOAHANGSPXOATHEO 'HSXTHU'
DELETE FROM tbl_HANGSX WHERE sIDHang = 'HSXTHU'

--TRIGGER K ĐC XÓA TRG TRONG NHAPP

--9. trigger hiển thị tổng nv nam, nữ sau khi thêm nhân viên
ALTER TRIGGER HIENTONGNAMNU
ON TBL_NHANVIEN
FOR INSERT
AS
BEGIN
		DECLARE @MALE INT, @FEMALE INT
		SELECT @MALE = COUNT(sIDNV) FROM tbl_NHANVIEN WHERE sGioiTinh = 'NAM'
		SELECT @FEMALE = COUNT(sIDNV) FROM tbl_NHANVIEN WHERE sGioiTinh = N'NỮ'

		PRINT'TONG SO NV NAM LA: ' + CAST(@MALE AS NVARCHAR)
		PRINT'TONG SO NV NU LA: ' + CAST(@FEMALE AS NVARCHAR)
END
INSERT into tbl_NHANVIEN (sIDNV, sTenNV, dNgaySinh, dNgayVaoLam, sGioiTinh, sSDT, sViTri, fHSL)
VALUES	('nv015',N'Phan Duy Hùng','1995-10-01','2018-04-19',N'Nam','0338265110',N'Bán hàng', 4.8)
DROP TRIGGER HIENTONGNAMNU

--10 Trigger khi thêm nhân viên tuổi nhân viên phải trên 18 tuổi
ALTER TRIGGER NVTUOIHON18
ON tbl_NHANVIEN
AFTER INSERT
AS
	BEGIN
		DECLARE @tuoi_nvmoi INT
	SET @tuoi_nvmoi = ( SELECT year(getdate())-year(dNgaySinh) AS tuoi_nv FROM INSERTED)
	IF(@tuoi_nvmoi < 18)
     BEGIN 
            RAISERROR ('nhan vien khong duoc nho hon 18 tuoi',16,1)
			--PRINT('nhan vien khong duoc nho hon 18 tuoi')
			ROLLBACK TRAN
     END
END

--ktra
INSERT into tbl_NHANVIEN (sIDNV, sTenNV, dNgaySinh, dNgayVaoLam, sGioiTinh, sSDT, sViTri, fHSL)
VALUES ('nv12',N'Phan Công Minh','2020-11-02','2022-06-20',N'Nam','0398293833',N'Bán hàng', 4);
GO

--11 GIỚI TÍNH GIẢNG VIÊN CHỈ ĐƯỢC LÀ NAM HOẶC NỮ
CREATE TRIGGER GV_GT
ON tbl_NHANVIEN
AFTER INSERT
As
BEGIN
	DECLARE @gt NVARCHAR(5)
	SELECT @gt = sGioiTinh from INSERTED
	IF ( @gt NOT IN ('Nam', N'Nữ') )
	BEGIN
		PRINT('Ban nhap sai Gioi tinh')
		ROLLBACK TRAN
	END
END
GO
INSERT into tbl_NHANVIEN (sIDNV, sTenNV, dNgaySinh, dNgayVaoLam, sGioiTinh, sSDT, sViTri, fHSL)
VALUES	('nv014',N'Phan Duy Hùng','1995-10-01','2018-04-19',N'NamS','0338265110',N'Bán hàng', 4.8)
GO


------------------------------------------ Tham khảo----------------------------------------------------------------
--UPDATE: UPDATE table_name SET column1 = value1 WHERE condition;
--DELETE: DELETE FROM table_name WHERE condition;
--1 trigger k thể xóa sp có mã = sp01
--2 trigger k thể xóa sp có dung lượng đĩa 512
--3 trigger giá sp tối thiểu > 100
--4 trigger k thể xóa các trường dl trong tbl_sp(ĐÚNG)
--5 trigger đếm số lượng sp bị xóa, khi thực hiện xóa trên bảng sp
--6 Trigger đếm số sp bị xóa mà có màu đen
--7 3 trụ thêm sửa xóa 


--1 trigger k thể xóa sp có mã = sp01
CREATE TRIGGER KXOAIDMASP
ON TBL_SANPHAM
FOR DELETE
AS
BEGIN
	IF('SP01') IN(SELECT sIDSP FROM deleted)
	BEGIN
	PRINT'BAN K THE XOA BAN GHI NAY'
	ROLLBACK TRAN
	END
END
GO
--2 trigger k thể xóa sp có dung lượng đĩa 512
CREATE TRIGGER KXOASPDUNGLUONG512
ON TBL_SANPHAM
FOR DELETE
AS
BEGIN
	IF EXISTS(SELECT * FROM DELETED WHERE iDungLuongDia = 512)
	BEGIN
		PRINT 'K THE XOA SP CO DUNG LUONG 512'
		ROLLBACK TRAN
	END
END
--3 trigger giá sp tối thiểu > 100
CREATE TRIGGER CHEC_GIASP
ON TBL_SANPHAM
FOR INSERT, UPDATE
AS
BEGIN
	if(select iGiaBan from inserted) < 100
	BEGIN
		PRINT 'GIA BAN TOI THIEU LON HƠN 100'
	END
END
select * from tbl_SANPHAM

--4 trigger k thể xóa các trường dl trong tbl_sp(ĐÚNG)
CREATE TRIGGER KTHEXOATRUONGSP
ON TBL_SANPHAM
FOR DELETE
AS
BEGIN
	IF EXISTS(SELECT * FROM deleted)
	BEGIN
		PRINT'K THE XOA TRG DL TRONG TBL_SP'
		ROLLBACK TRAN
	END
END

DELETE FROM tbl_DONGHOADON
WHERE sIDSP = 'SPTHU1'
-- 5 trigger đếm số lượng sp bị xóa, khi thực hiện xóa trên bảng sp
CREATE TRIGGER DEMSLSPBIXOA
ON TBL_SANPHAM
FOR DELETE
AS
BEGIN
	DECLARE @NUM NCHAR
	SELECT @NUM = COUNT(*) FROM deleted
	PRINT'SO LUONG DA XOA LA' + @NUM
END
--6 Trigger đếm số sp bị xóa mà có màu đen
CREATE TRIGGER DEMSOSPBIXOAMAUDEN
ON TBL_SANPHAM
FOR DELETE
AS
BEGIN
	DECLARE @NUM INT
	SELECT @NUM = COUNT(*) FROM deleted WHERE sMauSac = N'ĐEN'
	PRINT'TONG SO SP CO MAU DEN BỊ XOA LA' + CAST(@NUM AS VARCHAR)
END

--7 3 trụ thêm sửa xóa theo link: https://viblo.asia/p/su-dung-trigger-trong-sql-qua-vi-du-co-ban-aWj538APK6m
--khi thêm số lượng bán trong dòng hóa đơn thì số lượng tồn kho giảm theo
CREATE TRIGGER TRG_THEM
ON TBL_DONGHOADON
FOR INSERT 
AS
BEGIN
	UPDATE tbl_SANPHAM
	SET iTonKho = iTonKho - (SELECT iSoLuongBan FROM inserted WHERE sIDSP = tbl_SANPHAM.sIDSP)
	FROM tbl_SANPHAM JOIN inserted ON tbl_SANPHAM.sIDSP = inserted.sIDSP 
END

--khi update số lượng bán trong dòng hóa đơn thì số lượng tồn kho update theo
CREATE TRIGGER TRG_UPDATE
ON TBL_DONGHOADON
FOR UPDATE 
AS
BEGIN
	UPDATE tbl_SANPHAM
	SET iTonKho = iTonKho - 
	(SELECT iSoLuongBan FROM inserted WHERE sIDSP = tbl_SANPHAM.sIDSP) + 
	(SELECT iSoLuongBan FROM deleted WHERE sIDSP = tbl_SANPHAM.sIDSP)
	FROM tbl_SANPHAM JOIN deleted ON tbl_SANPHAM.sIDSP = deleted.sIDSP 
END

--khi xóa số lượng bán trong dòng hóa đơn thì số lượng tồn kho xóa theo
CREATE TRIGGER TRG_XOA
ON TBL_DONGHOADON
FOR DELETE 
AS
BEGIN
	UPDATE tbl_SANPHAM
	SET iTonKho = iTonKho + (SELECT iSoLuongBan FROM deleted WHERE sIDSP = tbl_SANPHAM.sIDSP)
	FROM tbl_SANPHAM JOIN deleted ON tbl_SANPHAM.sIDSP = deleted.sIDSP 
END



SELECT sIDSP, sIDHD, iSoLuongBan, iDonGiaBan, (iSoLuongBan * iDonGiaBan) AS THANHTIEN FROM tbl_DONGHOADON