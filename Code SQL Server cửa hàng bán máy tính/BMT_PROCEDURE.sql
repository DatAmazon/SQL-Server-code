--1.Tạo thủ tục hiển thị tổng tiền của 1 hóa đơn bán, với mã hóa đơn là tham số truyền vào
--2.Tạo thủ tục hiển thị tổng tiền bán được trong 1 ngày, với số ngày là tham số truyền vào
--3.Thủ tục hiện gv có tuổi cao nhất
--5.Thêm sản phẩm nếu có mã sản phẩm đó thì báo lỗi
--6.Nhập nhân viên trong đó ngày vào làm không được quá ngày hiện tại, nhân viên vào làm phải từ 18 tuổi trở lên
--7.Thủ tục đếm  gv nam và gv nữ và tổng cả 2	
--8.Update hãng nếu k tồn tại mã nhân viên thì báo lỗi
--9.Truyền vào mã sản phẩm xóa sản phẩm đó, nêu sp đó có trong donghoadon thì báo k xóa dc, nếu k báo xóa thành công
--10.Thêm 1 trường hoadonban, kiểm tra nếu k có manv, makh tg ứng báo lỗi, còn lại báo thành công



--Điều kiện IN được dùng trong SQL để giảm thiểu việc phải sử dụng quá nhiều điều kiện OR 

--1.Tạo thủ tục hiển thị tổng tiền của 1 hóa đơn bán, với mã hóa đơn là tham số truyền vào
CREATE PROC prTongHoaDon
@idHoaDon NVARCHAR(10)
as
	Begin
		Select tbl_HOADONBAN.*, (Select sum(tbl_SANPHAM.iGiaBan * tbl_DONGHOADON.iSoLuongBan) as N'Thành tiền' from tbl_DONGHOADON inner join tbl_SANPHAM
		on tbl_SANPHAM.sIDSP = tbl_DONGHOADON.sIDSP where tbl_DONGHOADON.sIDHD = @idHoaDon group by tbl_DONGHOADON.sIDHD) as N'Tổng tiền' from tbl_HOADONBAN where tbl_HOADONBAN.sIDHD = @idHoaDon
	end;

exec prTongHoaDon 'hd01';

GO
--2.Tạo thủ tục hiển thị tổng tiền bán được trong 1 ngày, với số ngày là tham số truyền vào
CREATE PROC prTongHoaDonNgay
@ngayTinh DATE
as
	begin
		select sum(tbl_DONGHOADON.iSoLuongBan * tbl_SANPHAM.iGiaBan) as N'Tổng tiền' 
		from tbl_DONGHOADON inner join tbl_SANPHAM
		on tbl_SANPHAM.sIDSP = tbl_DONGHOADON.sIDSP
		where tbl_DONGHOADON.sIDHD between (select top 1 sIDHD from tbl_HOADONBAN 
		where tbl_HOADONBAN.dNgaylap = @ngayTinh order by sIDHD asc) 
		and (select top 1 sIDHD from tbl_HOADONBAN
		where tbl_HOADONBAN.dNgaylap = @ngayTinh order by sIDHD desc)
	end;

exec prTongHoaDonNgay '2019-05-29'
GO
--3.Thủ tục hiện gv có tuổi cao nhất(chưa đúng lắm)
CREATE PROC TUOICAONHAT
@TCAONHAT INT OUTPUT,
@TENNV NVARCHAR(20) OUTPUT
AS
	SELECT ALL @TENNV=sTenNV ,@TCAONHAT=YEAR(GETDATE())-YEAR(dNgaysinh)  FROM tbl_NHANVIEN
	WHERE YEAR(GETDATE())-YEAR(dNgaysinh)>=ALL(SELECT YEAR(GETDATE())-YEAR(dNgaysinh) FROM tbl_NHANVIEN)

DECLARE @TC INT,@TNV NVARCHAR(20) 
EXEC TUOICAONHAT 
@TCAONHAT=@TC OUTPUT,@TENNV=@TNV OUTPUT

GO

--Thủ tục hiện gv có tuổi cao nhất(đúng nhưng k có tham số output)
CREATE PROC TUOICAONHAT2
AS
	SELECT ALL STENNV,YEAR(GETDATE())-YEAR(dNgaysinh) tuoicao1  FROM tbl_NHANVIEN
	WHERE YEAR(GETDATE())-YEAR(dNgaysinh)>=ALL(SELECT YEAR(GETDATE())-YEAR(dNgaysinh) FROM tbl_NHANVIEN)
EXEC TUOICAONHAT2
GO
--5.Thêm sản phẩm nếu có mã sản phẩm đó thì báo lỗi
CREATE PROC ThemSpNeuCoBaoLoi
@sIDSP NVARCHAR(10),
@sIDHang NVARCHAR(10),
@sIDNPP NVARCHAR(10),
@sTenSeries NVARCHAR(30),
@iBaoHanh INT,
@sTenCPU NVARCHAR(30),
@iDungLuongRAM INT,
@sMauSac NVARCHAR(30),
@sLoaiODia NVARCHAR(10),
@iDungLuongDia INT,
@iNamSX INT,
@iGiaBan INT,
@iTonKho INT
AS
	IF EXISTS(SELECT sIDSP FROM tbl_SANPHAM WHERE @sIDSP = sIDSP)
		BEGIN
			PRINT N'ĐÃ XẢY RA LỖI VUI LÒNG KIỂM TRA'
			RETURN 
		END
	ELSE
		BEGIN
			INSERT INTO tbl_SANPHAM VALUES(@sIDSP, @sIDHang, @sIDNPP, @sTenSeries, @iBaoHanh,
				@sTenCPU, @iDungLuongRAM, @sMauSac, @sLoaiODia, @iDungLuongDia, @iNamSX, @iGiaBan, @iTonKho)
			PRINT N'NHẬP THÀNH CÔNG'
		END
EXEC INSERT_PRODUCT 'sp013','hsx03','npp04','Elitebook',24,'Intel Core I5',8,N'Đen','SSD NVME',512,2020,30000,0
GO
--6.Nhập nhân viên trong đó ngày vào làm không được quá ngày hiện tại, nhân viên vào làm phải từ 18 tuổi trở lên
Create procedure prAddNhanVien
@nhanvien_id nvarchar(10), @tenNhanVien nvarchar(30), @ngaySinh date, @ngayVaoLam date, @gioitinh int, @sdt nvarchar(12), @vitri nvarchar(30), @hesoluong float
as
Begin
if	(DATEDIFF(DAY,GETDATE(),@ngayVaoLam) <=0 and DATEDIFF(year, @ngaySinh, @ngayVaoLam) >= 18)
	if (@gioitinh = 1)
		insert into tbl_NHANVIEN(sIDNV,sTenNV,dNgaySinh,dNgayVaoLam,sGioiTinh,sSDT,sViTri,fHSL)
		values (@nhanvien_id,@tenNhanVien,@ngaySinh,@ngayVaoLam,N'Nữ',@sdt,@vitri,@hesoluong)
	else
		insert into tbl_NHANVIEN(sIDNV,sTenNV,dNgaySinh,dNgayVaoLam,sGioiTinh,sSDT,sViTri,fHSL)
		values (@nhanvien_id,@tenNhanVien,@ngaySinh,@ngayVaoLam,N'Nam',@sdt,@vitri,@hesoluong)
else
	return 1
end;

exec prAddNhanVien 'nv13',N'Nhân viên A','2009-12-12','2020-08-10',1,'0965892259',N'Bán hàng',2.3;
GO

--7.Thủ tục đếm  gv nam và gv nữ VÀ TỔNG CẢ 2
CREATE  PROC spDemNhanvien
@Nam INT OUTPUT,
@Nu INT OUTPUT
AS
	SET @Nam=0
	SET @Nu=0
	SELECT @Nam=COUNT(*)	FROM  tbl_NHANVIEN
	WHERE sGioitinh='Nam';
	SELECT @Nu=COUNT(*)	FROM  tbl_NHANVIEN
	WHERE sGioitinh=N'Nữ';
	RETURN @NAM+@NU --Tổng số nhân viên

DECLARE @H INT, @M INT, @T INT  
EXEC @T= spDemNhanvien 
@NAM=@H OUTPUT, 
@NU=@M OUTPUT
SELECT @H AS [Nam], @M AS [Nữ], @T AS [Tổng]
GO
--8.Update hãng nếu k tồn tại mã nhân viên thì báo lỗi
CREATE PROC UPDATEHANG
@IDHANG NVARCHAR(10),
@TENHANG NVARCHAR(30),
@QUOCGIA NVARCHAR(30)
AS
BEGIN
	IF EXISTS (SELECT sIDHANG FROM tbl_HANGSX WHERE sIDHang = @IDHANG)
	BEGIN 
		UPDATE tbl_HANGSX
		SET sTenHang = @TENHANG,
		sQuocGia = @QUOCGIA
		WHERE sIDHang = @IDHANG

		PRINT 'CAP NHAT THANH CON MA HANG: ' + @IDHANG
		RETURN 1
	END
	ELSE 
		PRINT 'K TON TAI MA HANG : ' + @IDHANG
END

EXEC UPDATEHANG 'HSX044','EVOO', N'HOA KỲ' 
GO

--9.Truyền vào mã sản phẩm xóa sản phẩm đó, nêu sp đó có trong donghoadon thì báo k xóa dc, nếu k báo xóa thành công
CREATE PROC XOASPTHEOIDs
@sIDSP NVARCHAR(10)
AS 
BEGIN
	IF NOT EXISTS (SELECT sIDSP FROM tbl_SANPHAM WHERE sIDSP = @sIDSP)
		PRINT 'MA SP K TON TAI : '+ @sIDSP
	IF EXISTS (SELECT sIDSP FROM tbl_DONGHOADON WHERE sIDSP = @sIDSP)
		PRINT 'MA DA DUOC BAN, K THE XOA'
	ELSE
	BEGIN
		DELETE FROM tbl_SANPHAM
		WHERE sIDSP = @sIDSP
		PRINT ' XOA THANH CONG'
	END
END
EXEC XOASPTHEOIDS 'SP013'
SELECT * FROM TBL_SANPHAM
GO
--10.Thêm 1 trường hoadonban, kiểm tra nếu k có manv, makhtg ứng báo lỗi, còn lại báo thành công
CREATE PROC THEMHOADONBAN
@sIDHD NVARCHAR(10),
@sIDNV NVARCHAR(10),
@sIDKH NVARCHAR(10),
@dNGAYLAP DATE
AS 
BEGIN
	IF NOT EXISTS (SELECT sIDNV FROM tbl_NHANVIEN WHERE sIDNV = @sIDNV)
		PRINT 'MA NV K TON TAI : '+ @sIDNV
	IF NOT EXISTS (SELECT sIDKH FROM tbl_KHACHHANG WHERE sIDKH = @sIDKH)
		PRINT 'MA KH K TON TAI : '+ @sIDKH
	ELSE
	BEGIN
		INSERT INTO tbl_HOADONBAN VALUES(@sIDHD, @sIDNV, @sIDKH, @dNGAYLAP)
	END
END
EXEC THEMHOADONBAN 'HD12', 'NV08', 'KH013', '2022-6-30'
SELECT * FROM TBL_SANPHAM
GO

















---------------------------OUTPUT------------------------------
--11. Cho biết số nhân viên sinh trong 1 tháng với tháng là tham số truyền vào, số lượng là tham số trả về
CREATE PROC OutputQuatityByMonth
@THANG INT,
@SOLG INT OUTPUT
AS
	SELECT @SOLG = COUNT(sIDNV) FROM tbl_NHANVIEN
	WHERE @THANG = MONTH(dNgaysinh)
DECLARE @SO INT
EXEC OutputQuatityByMonth @THANG = 9, @SOLG = @SO OUTPUT
SELECT @SO AS SOLUONG

-- thêm cột: ALTER TABLE Quantrimang ADD Bientap VARCHAR(50), abc VARCHAR(50) 
-- sửa cột: ALTER TABLE Quantrimang ALTER COLUMN Trangthai VARCHAR(75) NOT NULL;
-- xóa cột: ALTER TABLE Quantrimang DROP COLUMN Bientap;
-- Đổi tên cột của bảng: EXEC sp_rename 'ten_bang.ten_cot_cu', 'ten_cot_moi', 'COLUMN';
-- đổi tên bảng: EXEC sp_rename 'old_table_name', 'new_table_name'
