CREATE DATABASE RaceDay;
USE RaceDay;

CREATE DATABASE RACEDAY;
USE RACEDAY;

CREATE DATABASE RACEDAY;
USE RACEDAY;

-- Drop existing tables first (child tables before parent tables)
DROP TABLE IF EXISTS Results;
DROP TABLE IF EXISTS Enrolments;
DROP TABLE IF EXISTS WeatherInfo;
DROP TABLE IF EXISTS Routes;
DROP TABLE IF EXISTS Categories;
DROP TABLE IF EXISTS Events;
DROP TABLE IF EXISTS Users;


CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    Role VARCHAR(20) NOT NULL DEFAULT 'Participant'
        CHECK (Role IN ('Organiser', 'Participant')),
    PhoneNumber VARCHAR(20),
    DateOfBirth DATE,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE()
);


CREATE TABLE Events (
    EventID INT IDENTITY(1,1) PRIMARY KEY,
    OrganiserID INT NOT NULL,
    EventName VARCHAR(150) NOT NULL,
    EventDate DATE NOT NULL,
    Location VARCHAR(150) NOT NULL,
    Description VARCHAR(1000) NULL,
    EventType VARCHAR(20) NOT NULL
        CHECK (EventType IN ('Running', 'Walking', 'Cycling')),
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Events_Organiser FOREIGN KEY (OrganiserID)
        REFERENCES Users(UserID)
);


CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    EventID INT NOT NULL,
    CategoryName VARCHAR(100) NOT NULL,
    Distance DECIMAL(6,2) NOT NULL,         
    EntryFee DECIMAL(8,2) NOT NULL DEFAULT 0,
    MaxParticipants INT NULL,
    CONSTRAINT FK_Categories_Event FOREIGN KEY (EventID)
        REFERENCES Events(EventID)
);


CREATE TABLE Routes (
    RouteID INT IDENTITY(1,1) PRIMARY KEY,
    EventID INT NOT NULL,
    RouteName VARCHAR(100) NOT NULL,
    DistanceKm DECIMAL(6,2) NOT NULL,
    ElevationGainM INT NULL,
    CONSTRAINT FK_Routes_Event FOREIGN KEY (EventID)
        REFERENCES Events(EventID)
);


CREATE TABLE WeatherInfo (
    WeatherID INT IDENTITY(1,1) PRIMARY KEY,
    EventID INT NOT NULL,
    ForecastDate DATE NOT NULL,
    TemperatureC DECIMAL(4,1) NULL,
    WeatherCondition VARCHAR(50) NULL,
    WindSpeedKmh DECIMAL(5,1) NULL,
    ChanceOfRainPercent INT NULL,
    CONSTRAINT FK_Weather_Event FOREIGN KEY (EventID)
        REFERENCES Events(EventID)
);

CREATE TABLE Enrolments (
    EnrolmentID INT IDENTITY(1,1) PRIMARY KEY,
    ParticipantID INT NOT NULL,
    EventID INT NOT NULL,
    CategoryID INT NOT NULL,
    BibNumber VARCHAR(20) NULL,
    RegistrationDate DATETIME NOT NULL DEFAULT GETDATE(),
    PaymentStatus VARCHAR(20) NOT NULL DEFAULT 'Pending'
        CHECK (PaymentStatus IN ('Pending', 'Paid', 'Cancelled')),
    CONSTRAINT FK_Enrolments_Participant FOREIGN KEY (ParticipantID)
        REFERENCES Users(UserID),
    CONSTRAINT FK_Enrolments_Event FOREIGN KEY (EventID)
        REFERENCES Events(EventID),
    CONSTRAINT FK_Enrolments_Category FOREIGN KEY (CategoryID)
        REFERENCES Categories(CategoryID)
);


CREATE TABLE Results (
    ResultID INT IDENTITY(1,1) PRIMARY KEY,
    EnrolmentID INT NOT NULL UNIQUE,
    FinishTime TIME NULL,
    OverallPosition INT NULL,
    CategoryPosition INT NULL,
    Status VARCHAR(20) NOT NULL DEFAULT 'Finished'
        CHECK (Status IN ('Finished', 'DNF', 'DSQ')),
    CONSTRAINT FK_Results_Enrolment FOREIGN KEY (EnrolmentID)
        REFERENCES Enrolments(EnrolmentID)
);

INSERT INTO Users (FullName, Email, PasswordHash, Role, PhoneNumber, DateOfBirth)
VALUES
    ('Thabo Nkosi', 'thabo.nkosi@raceday.co.za', 'hashed_pw_001', 'Organiser', '0821234567', '1985-03-14'),
    ('Lindiwe Dube', 'lindiwe.dube@raceday.co.za', 'hashed_pw_002', 'Organiser', '0837654321', '1990-07-22'),
    ('Johan van der Merwe', 'johan.vdm@example.com', 'hashed_pw_003', 'Participant', '0741122334', '1995-11-02'),
    ('Naledi Mokoena', 'naledi.mokoena@example.com', 'hashed_pw_004', 'Participant', '0765544332', '1998-01-19');

INSERT INTO Events (OrganiserID, EventName, EventDate, Location, Description, EventType)
VALUES
    (1, 'Comrades Marathon', '2026-06-14', 'Pietermaritzburg to Durban',
        'Iconic ultramarathon between Pietermaritzburg and Durban.', 'Running'),
    (1, 'Cape Town Cycle Tour', '2026-03-08', 'Cape Town',
        'Scenic road cycling event around the Cape Peninsula.', 'Cycling'),
    (2, 'Soweto Marathon', '2026-11-01', 'Soweto, Johannesburg',
        'Community road running event through the streets of Soweto.', 'Running');


INSERT INTO Categories (EventID, CategoryName, Distance, EntryFee, MaxParticipants)
VALUES
   
    (1, 'Full Ultramarathon', 89.00, 950.00, 20000),
    (2, '109km Cycle', 109.00, 650.00, 15000),
    (2, '56km Cycle', 56.00, 450.00, 10000),
    (3, '42.2km Marathon', 42.20, 350.00, 8000),
    (3, '21.1km Half Marathon', 21.10, 250.00, 8000),
    (3, '10km Fun Run', 10.00, 150.00, 5000);


INSERT INTO Routes (EventID, RouteName, DistanceKm, ElevationGainM)
VALUES
    (1, 'Down Run Route', 89.00, 1200),
    (2, 'Peninsula Loop', 109.00, 950),
    (3, 'Soweto Streets Route', 42.20, 320);

INSERT INTO WeatherInfo (EventID, ForecastDate, TemperatureC, WeatherCondition, WindSpeedKmh, ChanceOfRainPercent)
VALUES
    (1, '2026-06-14', 14.5, 'Partly Cloudy', 12.0, 10),
    (2, '2026-03-08', 22.0, 'Sunny', 18.5, 5),
    (3, '2026-11-01', 19.0, 'Clear', 8.0, 0);

INSERT INTO Enrolments (ParticipantID, EventID, CategoryID, BibNumber, PaymentStatus)
VALUES
    (3, 1, 1, 'CM2026-1042', 'Paid'),     
    (4, 2, 2, 'CT2026-0587', 'Paid'),     
    (3, 3, 4, 'SW2026-2210', 'Paid'),     
    (4, 3, 5, 'SW2026-2211', 'Pending');  
INSERT INTO Results (EnrolmentID, FinishTime, OverallPosition, CategoryPosition, Status)
VALUES
    (1, '08:45:30', 1523, 1523, 'Finished'),
    (2, '03:12:10', 842, 512, 'Finished');

SELECT * FROM Users;
SELECT * FROM Events;
SELECT * FROM Categories;
SELECT * FROM Routes;
SELECT * FROM WeatherInfo;
SELECT * FROM Enrolments;
SELECT * FROM Results;