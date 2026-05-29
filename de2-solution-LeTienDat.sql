--BÀI 2:
-- ============================================================================
-- DATABASE SETUP: Tạo và sử dụng Database Tuan2
-- ============================================================================
USE Tuan2;
GO

-- ============================================================================
-- SCHEMA CREATION: Tạo cấu trúc các bảng theo đề bài
-- ============================================================================

-- Bảng Hackers: Lưu thông tin người tham gia
IF OBJECT_ID('dbo.Hackers', 'U') IS NOT NULL DROP TABLE dbo.Hackers;
CREATE TABLE Hackers (
    hacker_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Bảng Difficulty: Lưu mức độ khó và điểm số tối đa tương ứng
IF OBJECT_ID('dbo.Difficulty', 'U') IS NOT NULL DROP TABLE dbo.Difficulty;
CREATE TABLE Difficulty (
    difficulty_level INT PRIMARY KEY,
    score INT NOT NULL
);

-- Bảng Challenges: Lưu thông tin các thử thách
IF OBJECT_ID('dbo.Challenges', 'U') IS NOT NULL DROP TABLE dbo.Challenges;
CREATE TABLE Challenges (
    challenge_id INT PRIMARY KEY,
    hacker_id INT,
    difficulty_level INT
);

-- Bảng Submissions: Lưu các bài nộp của hackers
IF OBJECT_ID('dbo.Submissions', 'U') IS NOT NULL DROP TABLE dbo.Submissions;
CREATE TABLE Submissions (
    submission_id INT PRIMARY KEY,
    hacker_id INT,
    challenge_id INT,
    score INT
);
GO

-- ============================================================================
-- MOCK DATA: Chèn dữ liệu mẫu dựa trên mô tả đề bài để test
-- ============================================================================

-- Dữ liệu bảng Hackers
INSERT INTO Hackers (hacker_id, name) VALUES 
(86870, 'Hacker A'),
(90411, 'Joe');

-- Dữ liệu bảng Difficulty
INSERT INTO Difficulty (difficulty_level, score) VALUES 
(2, 30),
(6, 100);

-- Dữ liệu bảng Challenges
INSERT INTO Challenges (challenge_id, hacker_id, difficulty_level) VALUES 
(71055, 86870, 2),
(66730, 90411, 6);

-- Dữ liệu bảng Submissions
INSERT INTO Submissions (submission_id, hacker_id, challenge_id, score) VALUES 
(1, 86870, 71055, 30),   -- 86870 đạt điểm tối đa bài 71055 (1 bài)
(2, 90411, 71055, 30),   -- 90411 đạt điểm tối đa bài 71055
(3, 90411, 66730, 100);  -- 90411 đạt điểm tối đa bài 66730 (Tổng cộng 2 bài)
GO

-- ============================================================================
-- SOLUTION QUERY: Câu lệnh truy vấn đáp án nộp lên HackerRank
-- ============================================================================
/* Yêu cầu: In ra ID và tên của các hacker đạt điểm tối đa ở nhiều hơn 1 thử thách.
Sắp xếp: Số lượng bài tối đa giảm dần, nếu trùng thì ID tăng dần.
*/

SELECT 
    h.hacker_id, 
    h.name
FROM Submissions s
JOIN Hackers h ON s.hacker_id = h.hacker_id
JOIN Challenges c ON s.challenge_id = c.challenge_id
JOIN Difficulty d ON c.difficulty_level = d.difficulty_level
WHERE s.score = d.score
GROUP BY h.hacker_id, h.name
HAVING COUNT(s.challenge_id) > 1
ORDER BY COUNT(s.challenge_id) DESC, h.hacker_id ASC;
GO