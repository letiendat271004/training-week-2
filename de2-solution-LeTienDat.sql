-- BÀI 2
--
USE Tuan2;
GO

-- Bảng Hackers
IF OBJECT_ID('dbo.Hackers', 'U') IS NOT NULL
    DROP TABLE dbo.Hackers;

CREATE TABLE Hackers (
    hacker_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Bảng Difficulty
IF OBJECT_ID('dbo.Difficulty', 'U') IS NOT NULL
    DROP TABLE dbo.Difficulty;

CREATE TABLE Difficulty (
    difficulty_level INT PRIMARY KEY,
    score INT NOT NULL
);

-- Bảng Challenges
IF OBJECT_ID('dbo.Challenges', 'U') IS NOT NULL
    DROP TABLE dbo.Challenges;

CREATE TABLE Challenges (
    challenge_id INT PRIMARY KEY,
    hacker_id INT,
    difficulty_level INT
);

-- Bảng Submissions
IF OBJECT_ID('dbo.Submissions', 'U') IS NOT NULL
    DROP TABLE dbo.Submissions;

CREATE TABLE Submissions (
    submission_id INT PRIMARY KEY,
    hacker_id INT,
    challenge_id INT,
    score INT
);
GO

-- Dữ liệu mẫu Hackers
INSERT INTO Hackers (hacker_id, name)
VALUES
    (86870, 'Hacker A'),
    (90411, 'Joe');

-- Dữ liệu mẫu Difficulty
INSERT INTO Difficulty (difficulty_level, score)
VALUES
    (2, 30),
    (6, 100);

-- Dữ liệu mẫu Challenges
INSERT INTO Challenges (challenge_id, hacker_id, difficulty_level)
VALUES
    (71055, 86870, 2),
    (66730, 90411, 6);

-- Dữ liệu mẫu Submissions
INSERT INTO Submissions (submission_id, hacker_id, challenge_id, score)
VALUES
    (1, 86870, 71055, 30),
    (2, 90411, 71055, 30),
    (3, 90411, 66730, 100);
GO

/*
Yêu cầu:
In ra hacker_id và name của các hacker đạt điểm tối đa
ở nhiều hơn một challenge.

Sắp xếp:
- Số challenge đạt điểm tối đa giảm dần.
- Nếu bằng nhau thì hacker_id tăng dần.
*/

SELECT
    h.hacker_id,
    h.name
FROM Hackers h
JOIN Submissions s
    ON h.hacker_id = s.hacker_id
JOIN Challenges c
    ON s.challenge_id = c.challenge_id
JOIN Difficulty d
    ON c.difficulty_level = d.difficulty_level
WHERE s.score = d.score
GROUP BY
    h.hacker_id,
    h.name
HAVING COUNT(DISTINCT s.challenge_id) > 1
ORDER BY
    COUNT(DISTINCT s.challenge_id) DESC,
    h.hacker_id ASC;
GO