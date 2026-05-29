--BÀI 1: 
USE Tuan2;
GO

CREATE TABLE CITY (
    ID INT PRIMARY KEY,
    NAME VARCHAR(17),
    COUNTRYCODE VARCHAR(3),
    DISTRICT VARCHAR(20),
    POPULATION INT
);
GO
SELECT * FROM CITY
WHERE COUNTRYCODE = 'USA' 
  AND POPULATION > 100000;
-- Hiển thị các thành phố của Mỹ theo dân số giảm dần
SELECT *
FROM CITY
WHERE COUNTRYCODE = 'USA'
ORDER BY POPULATION DESC;
-- Đếm số lượng thành phố thuộc Mỹ
SELECT COUNT(*) AS total_city
FROM CITY
WHERE COUNTRYCODE = 'USA';
-- Thống kê số lượng thành phố theo từng quốc gia
SELECT COUNTRYCODE,
       COUNT(*) AS total_city
FROM CITY
GROUP BY COUNTRYCODE;
-- Hiển thị các quốc gia có trên 5 thành phố
SELECT COUNTRYCODE,
       COUNT(*) AS total_city
FROM CITY
GROUP BY COUNTRYCODE
HAVING COUNT(*) > 5;
--Giải thích chi tiết:
--SELECT *: Lấy ra toàn bộ các cột (ID, NAME, COUNTRYCODE, DISTRICT, POPULATION) theo yêu cầu "truy vấn tất cả các cột".

--FROM CITY: Chỉ định truy vấn từ bảng tên là CITY.

--WHERE COUNTRYCODE = 'USA': Lọc ra các dòng thuộc quốc gia Mỹ (lưu ý mã quốc gia là chuỗi ký tự nên phải đặt trong dấu nháy đơn ' ').

--AND POPULATION > 100000: Kết hợp thêm điều kiện số dân phải lớn hơn 100,000. Do là kiểu số (NUMBER/INT) nên không cần dấu nháy đơn.