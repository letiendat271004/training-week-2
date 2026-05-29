--Bài 3: 
USE Tuan2;
GO


IF OBJECT_ID('dbo.Submissions', 'U') IS NOT NULL DROP TABLE dbo.Submissions;
IF OBJECT_ID('dbo.Hackers', 'U') IS NOT NULL DROP TABLE dbo.Hackers;

CREATE TABLE Hackers (
    hacker_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE Submissions (
    submission_date DATE,
    submission_id INT PRIMARY KEY,
    hacker_id INT,
    score INT
);
GO



WITH 
-- 1. Tính số ngày thi liên tiếp (tính từ ngày 01/03/2016) mà mỗi hacker đã tham gia
HackerConsecutiveDays AS (
    SELECT 
        submission_date,
        hacker_id,
        -- DATEDIFF + 1 để biết ngày hiện tại là ngày thứ mấy của cuộc thi (VD: ngày 1, ngày 2...)
        DATEDIFF(DAY, '2016-03-01', submission_date) + 1 AS ContestDayNumber,
        -- Đếm số ngày duy nhất mà hacker này đã nộp bài tính đến thời điểm hiện tại
        DENSE_RANK() OVER (PARTITION BY hacker_id ORDER BY submission_date) AS DaysSubmitted
    FROM Submissions
),

-- 2. Đếm tổng số lượng hacker "chăm chỉ" (ngày nào cũng nộp bài liên tục từ đầu giải đến ngày đó)
ChamiHackerCount AS (
    SELECT 
        submission_date,
        COUNT(DISTINCT hacker_id) AS TotalChamiHackers
    FROM HackerConsecutiveDays
    WHERE ContestDayNumber = DaysSubmitted -- Điều kiện cốt lõi: số ngày thi trôi qua = số ngày hacker đã nộp bài
    GROUP BY submission_date
),

-- 3. Đếm tổng số bài nộp của TỪNG hacker trong TỪNG ngày để tìm người nộp nhiều nhất
DailySubmissionCounts AS (
    SELECT 
        submission_date,
        hacker_id,
        COUNT(submission_id) AS TotalSubmissions
    FROM Submissions
    GROUP BY submission_date, hacker_id
),

-- 4. Tìm ra hacker có số lượng bài nộp nhiều nhất trong ngày (Xử lý trùng bằng cách lấy hacker_id nhỏ nhất)
TopDailyHackers AS (
    SELECT 
        submission_date,
        hacker_id,
        ROW_NUMBER() OVER (
            PARTITION BY submission_date 
            ORDER BY TotalSubmissions DESC, hacker_id ASC
        ) AS RankPosition
    FROM DailySubmissionCounts
)

-- 5. KẾT HỢP TẤT CẢ LẠI: Lấy số lượng hacker chăm chỉ + ID/Tên của top hacker mỗi ngày
SELECT 
    c.submission_date,
    c.TotalChamiHackers,
    t.hacker_id,
    h.name
FROM ChamiHackerCount c
JOIN TopDailyHackers t ON c.submission_date = t.submission_date AND t.RankPosition = 1
JOIN Hackers h ON t.hacker_id = h.hacker_id
ORDER BY c.submission_date ASC;
GO