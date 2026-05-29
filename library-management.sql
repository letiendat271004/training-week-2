```sql id="7u3s4x"
USE Tuan2;
GO

IF OBJECT_ID('dbo.borrowings', 'U') IS NOT NULL DROP TABLE dbo.borrowings;
IF OBJECT_ID('dbo.members', 'U') IS NOT NULL DROP TABLE dbo.members;
IF OBJECT_ID('dbo.books', 'U') IS NOT NULL DROP TABLE dbo.books;
GO

CREATE TABLE books (
    book_id INT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(100) NOT NULL,
    isbn VARCHAR(20) UNIQUE,
    quantity INT NOT NULL
);
GO

CREATE TABLE members (
    member_id INT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20)
);
GO

CREATE TABLE borrowings (
    borrowing_id INT PRIMARY KEY,
    member_id INT NOT NULL,
    book_id INT NOT NULL,
    borrow_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE NULL,

    FOREIGN KEY (member_id)
    REFERENCES members(member_id),

    FOREIGN KEY (book_id)
    REFERENCES books(book_id)
);
GO

INSERT INTO books VALUES
(1, 'SQL Basic', 'Nguyen Van A', 'ISBN001', 5),
(2, 'C# Programming', 'Tran Van B', 'ISBN002', 3),
(3, 'ASP.NET MVC', 'Le Van C', 'ISBN003', 2),
(4, 'ReactJS', 'Pham Van D', 'ISBN004', 4),
(5, 'Database Design', 'Hoang Van E', 'ISBN005', 1),
(6, 'Java Core', 'Nguyen Van F', 'ISBN006', 6),
(7, 'Python Basic', 'Tran Van G', 'ISBN007', 7),
(8, 'NodeJS Backend', 'Le Van H', 'ISBN008', 2),
(9, 'Docker Basic', 'Pham Van I', 'ISBN009', 3),
(10, 'Git & GitHub', 'Hoang Van K', 'ISBN010', 5);
GO

INSERT INTO members VALUES
(1, 'Nguyen Van Nam', 'nam@gmail.com', '0901'),
(2, 'Tran Thi Hoa', 'hoa@gmail.com', '0902'),
(3, 'Le Minh Tuan', 'tuan@gmail.com', '0903'),
(4, 'Pham Thanh Dat', 'dat@gmail.com', '0904'),
(5, 'Hoang Minh Anh', 'anh@gmail.com', '0905');
GO

INSERT INTO borrowings VALUES
(1, 1, 1, '2025-08-01', '2025-08-10', NULL),
(2, 1, 2, '2025-08-02', '2025-08-12', NULL),
(3, 2, 3, '2025-08-03', '2025-08-13', NULL),
(4, 2, 4, '2025-08-04', '2025-08-14', '2025-08-10'),
(5, 3, 5, '2025-08-05', '2025-08-15', NULL),
(6, 4, 1, '2025-08-06', '2025-08-16', NULL),
(7, 5, 2, '2025-08-07', '2025-08-17', NULL),
(8, 3, 1, '2025-08-08', '2025-08-18', NULL);
GO

SELECT 
    b.title,
    COUNT(br.book_id) AS total_borrow
FROM books b
JOIN borrowings br
ON b.book_id = br.book_id
GROUP BY b.title
ORDER BY total_borrow DESC;
GO

-- Giải thích:
-- JOIN borrowings để lấy các lượt mượn của từng sách.
-- COUNT(br.book_id): Đếm số lần sách được mượn.
-- GROUP BY b.title: Gom nhóm theo tên sách.
-- ORDER BY total_borrow DESC: Sắp xếp giảm dần theo số lượt mượn.

SELECT 
    m.full_name,
    COUNT(br.member_id) AS total_borrow
FROM members m
JOIN borrowings br
ON m.member_id = br.member_id
GROUP BY m.full_name
ORDER BY total_borrow DESC;
GO

-- Giải thích:
-- JOIN borrowings để lấy danh sách sách mà độc giả đã mượn.
-- COUNT(br.member_id): Đếm số lượt mượn của độc giả.
-- GROUP BY m.full_name: Gom nhóm theo tên độc giả.

SELECT 
    b.title,
    m.full_name,
    br.due_date
FROM borrowings br
JOIN books b
ON br.book_id = b.book_id
JOIN members m
ON br.member_id = m.member_id
WHERE br.return_date IS NULL
AND br.due_date < GETDATE();
GO

-- Giải thích:
-- return_date IS NULL:
-- Nghĩa là sách chưa được trả.
-- due_date < GETDATE():
-- Nghĩa là đã quá hạn trả sách.

SELECT *
FROM books
WHERE book_id NOT IN (
    SELECT DISTINCT book_id
    FROM borrowings
);
GO

-- Giải thích:
-- SELECT DISTINCT book_id:
-- Lấy danh sách các sách đã từng được mượn.
-- NOT IN:
-- Loại bỏ các sách đã tồn tại trong borrowings.

SELECT 
    b.title,
    COUNT(br.borrowing_id) AS total_borrow
FROM books b
LEFT JOIN borrowings br
ON b.book_id = br.book_id
GROUP BY b.title;
GO

-- Giải thích:
-- LEFT JOIN:
-- Hiển thị cả sách chưa từng được mượn.
-- COUNT(br.borrowing_id):
-- Đếm tổng số lượt mượn của từng sách.

IF OBJECT_ID('dbo.fn_CountBorrowingBooks', 'FN') IS NOT NULL
DROP FUNCTION dbo.fn_CountBorrowingBooks;
GO

CREATE FUNCTION fn_CountBorrowingBooks
(
    @MemberId INT
)
RETURNS INT
AS
BEGIN

    DECLARE @TotalBooks INT;

    SELECT @TotalBooks = COUNT(*)
    FROM borrowings
    WHERE member_id = @MemberId
    AND return_date IS NULL;

    RETURN @TotalBooks;

END;
GO

-- Giải thích:
-- Function nhận vào MemberId.
-- COUNT(*): Đếm số sách chưa trả.
-- return_date IS NULL:
-- Nghĩa là sách vẫn đang được mượn.

IF OBJECT_ID('dbo.sp_BorrowBook', 'P') IS NOT NULL
DROP PROCEDURE dbo.sp_BorrowBook;
GO

CREATE PROCEDURE sp_BorrowBook
(
    @BorrowingId INT,
    @MemberId INT,
    @BookId INT,
    @BorrowDate DATE,
    @DueDate DATE
)
AS
BEGIN

    DECLARE @AvailableBooks INT;

    SELECT @AvailableBooks =
    (
        quantity -
        (
            SELECT COUNT(*)
            FROM borrowings
            WHERE book_id = @BookId
            AND return_date IS NULL
        )
    )
    FROM books
    WHERE book_id = @BookId;

    IF @AvailableBooks <= 0
    BEGIN
        PRINT N'Sách đã hết.';
        RETURN;
    END

    IF EXISTS
    (
        SELECT 1
        FROM borrowings
        WHERE member_id = @MemberId
        AND return_date IS NULL
        AND due_date < GETDATE()
    )
    BEGIN
        PRINT N'Độc giả đang có sách quá hạn chưa trả.';
        RETURN;
    END

    INSERT INTO borrowings
    VALUES
    (
        @BorrowingId,
        @MemberId,
        @BookId,
        @BorrowDate,
        @DueDate,
        NULL
    );

    PRINT N'Mượn sách thành công.';

END;
GO

SELECT dbo.fn_CountBorrowingBooks(1) AS total_borrowing_books;
GO

EXEC sp_BorrowBook
    @BorrowingId = 9,
    @MemberId = 1,
    @BookId = 4,
    @BorrowDate = '2025-08-20',
    @DueDate = '2025-08-30';
GO

SELECT *
FROM borrowings;
GO
```
