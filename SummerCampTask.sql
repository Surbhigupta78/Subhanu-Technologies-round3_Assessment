CREATE DATABASE SummerCamp;
USE SummerCamp;
CREATE TABLE Camp (CampID INT PRIMARY KEY, CampTitle VARCHAR(255), StartDate DATE, EndDate DATE, Capacity INT, Price DECIMAL(10, 2));

INSERT INTO Camp (CampID, CampTitle, StartDate, EndDate, Capacity, Price) VALUES
(1, 'Summer Fun Camp', '2023-06-01', '2023-06-10', 100, 500.00),
(2, 'Adventure Camp', '2023-07-05', '2023-07-12', 80, 600.00),
(3, 'Tech Explorers Camp', '2023-08-15', '2023-08-22', 120, 550.00);

Select * from Camp;

CREATE TABLE Participant (ParticipantID INT PRIMARY KEY, FirstName VARCHAR(100), MiddleName VARCHAR(100), LastName VARCHAR(100), Email VARCHAR(255), DateOfBirth DATE, Gender CHAR(1), PersonalPhone VARCHAR(20));

INSERT INTO Participant (ParticipantID, FirstName, MiddleName, LastName, Email, DateOfBirth, Gender, PersonalPhone) VALUES
(1, 'Lakshmi', 'M', 'Rao', 'lakshmi.rao@example.com', '2008-05-21', 'F', '123-456-7890'),
(2, 'Aarav', 'K', 'Sharma', 'aarav.sharma@example.com', '2010-03-12', 'M', '123-456-7891'),
(3, 'Nisha', 'L', 'Patel', 'nisha.patel@example.com', '2007-11-25', 'F', '123-456-7892'),
(4, 'Rohan', 'N', 'Singh', 'rohan.singh@example.com', '2009-09-09', 'M', '123-456-7893'),
(5, 'Anjali', 'P', 'Kumar', 'anjali.kumar@example.com', '2012-02-15', 'F', '123-456-7894');

Select * from Participant;

CREATE TABLE Visit (VisitID INT PRIMARY KEY, ParticipantID INT, CampID INT, VisitDate DATE, FOREIGN KEY (ParticipantID) REFERENCES Participant(ParticipantID), FOREIGN KEY (CampID) REFERENCES Camp(CampID));

INSERT INTO Visit (VisitID, ParticipantID, CampID, VisitDate) VALUES
(1, 1, 1, '2022-06-05'),
(2, 1, 2, '2023-07-07'),
(3, 2, 1, '2023-06-06'),
(4, 3, 3, '2023-08-16'),
(5, 1, 3, '2023-08-18');  -- Lakshmi's third visit

Select * from Visit;



-- how many times a teenager Lakshmi visited the camp in last 3 years.

SELECT Participant.FirstName, COUNT(Visit.VisitID) AS VisitCount FROM Participant INNER JOIN  Visit ON Participant.ParticipantID = Visit.ParticipantID WHERE  Participant.FirstName = 'Lakshmi'  AND DATEDIFF(YEAR, Visit.VisitDate, GETDATE()) <= 3 GROUP BY  Participant.FirstName;


/* 
 Create a script that will populate one of your tables with a random 5000
people. Out of these 5000, 65% should be girls and 35% should be boys. Out of
these 5000, 18% should be between 7 and 12 years old, 27% should be 13 to14,
20% should be 15-17 and the rest could be any age up to 19 years old.
*/

WITH Numbers AS (
    SELECT TOP (5000) 
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS seq
    FROM 
        sys.objects AS o1
    CROSS JOIN sys.objects AS o2 ),
ParticipantData AS ( SELECT seq AS ParticipantID, CONCAT('FirstName', seq) AS FirstName, 'M' AS MiddleName,  CONCAT('LastName', seq) AS LastName, CONCAT('email', seq, '@example.com') AS Email,
     CASE   WHEN seq <= 3250 THEN DATEADD(YEAR, - (ABS(CHECKSUM(NEWID()) % (13 - 7 + 1)) + 7), GETDATE())
            WHEN seq <= 4600 THEN DATEADD(YEAR, - (ABS(CHECKSUM(NEWID()) % (17 - 14 + 1)) + 14), GETDATE())
            ELSE DATEADD(YEAR, - (ABS(CHECKSUM(NEWID()) % (19 - 15 + 1)) + 15), GETDATE())
        END AS DateOfBirth,
        CASE  WHEN seq <= 3250 THEN 'F'
            ELSE 'M'  END AS Gender,
        CONCAT('123-456-', RIGHT('0000' + CAST(seq AS VARCHAR(4)), 4)) AS PersonalPhone
    FROM Numbers )
INSERT INTO Participant (ParticipantID, FirstName, MiddleName, LastName, Email, DateOfBirth, Gender, PersonalPhone) SELECT ParticipantID,  FirstName,  MiddleName,  LastName,   Email,   DateOfBirth,  Gender,   PersonalPhone FROM  ParticipantData
WHERE NOT EXISTS ( SELECT 1 FROM Participant  WHERE Participant.ParticipantID = ParticipantData.ParticipantID);






SELECT CASE WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) BETWEEN 7 AND 12 THEN 'Gen Z'
        WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) BETWEEN 13 AND 14 THEN 'Millennials'
        WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) BETWEEN 15 AND 17 THEN 'Gen X'
        ELSE 'Gen Alpha' END AS Generation, Gender, COUNT(*) AS Count FROM  Participant GROUP BY 
		CASE  WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) BETWEEN 7 AND 12 THEN 'Gen Z'
        WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) BETWEEN 13 AND 14 THEN 'Millennials'
        WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) BETWEEN 15 AND 17 THEN 'Gen X'
        ELSE 'Gen Alpha'  END, Gender;
