----------------------------------- CELESTIA -----------------------------------

-- Saad Riaz | 23L-0669
-- Ahmed Zuhair | 23L-0931
-- Afnan Asif | 23L-0709

--------------------------------------------------------------------------------

-- Below is an outline of our schema with keys/attributes highlighted.

--------------------------------------------------------------------------------

-- 1. Users Table  
--- Primary Key (PK): UserID  
--- Foreign Keys (FK): None  
--- Attributes:  
--  - Username (NVARCHAR(50), NOT NULL, UNIQUE)  
--  - Email (NVARCHAR(100), NOT NULL, UNIQUE)  
--  - PasswordHash (NVARCHAR(255), NOT NULL)  
--  - CreatedAt (DATETIME2, DEFAULT: GETDATE())  

--------------------------------------------------------------------------------

-- 2. UserProfiles Table  
--- Primary Key (PK): ProfileID  
--- Foreign Keys (FK): UserID -> Users(UserID)  
--- Attributes:  
--  - FirstName (NVARCHAR(50))  
--  - LastName (NVARCHAR(50))  
--  - Bio (NVARCHAR(500))  

--------------------------------------------------------------------------------

-- 3. Friends Table  
--- Primary Key (PK): FriendshipID  
--- Foreign Keys (FK):  
--  - UserID -> Users(UserID)  
--  - FriendID -> Users(UserID)  
--- Attributes:  
--  - Status (NVARCHAR(20), CHECK: Pending, Accepted, Rejected)  
--  - RequestedAt (DATETIME2, DEFAULT: GETDATE())  
--  - RespondedAt (DATETIME2)  

--------------------------------------------------------------------------------

-- 4. CelestialBodies Table  
--- Primary Key (PK): BodyID  
--- Foreign Keys (FK): CreatedByUserID -> Users(UserID)  
--- Attributes:  
--  - Name (NVARCHAR(100), NOT NULL  
--  - Type (NVARCHAR(50), CHECK: Planet, Star, Moon, Asteroid, Comet, Dwarf Planet)  
--  - Mass (DECIMAL(30,10))  
--  - Diameter (DECIMAL(20,10))  
--  - Gravity (DECIMAL(10,4))  
--  - OrbitalPeriod (DECIMAL(15,5))  
--  - Description (NVARCHAR(MAX))  
--  - DiscoveredBy (NVARCHAR(100))  
--  - DiscoveryDate (DATE)  

--------------------------------------------------------------------------------

-- 5. UserNotes Table  
--- Primary Key (PK): NoteID  
--- Foreign Keys (FK):  
--  - UserID -> Users(UserID)  
--  - BodyID -> CelestialBodies(BodyID)  
--- Attributes:  
--  - NoteText (NVARCHAR(MAX))  
--  - CreatedAt (DATETIME2, DEFAULT: GETDATE())  
--  - UpdatedAt (DATETIME2)  

--------------------------------------------------------------------------------

-- 6. UserPlanets Table  
--- Primary Key (PK): UserPlanetID  
--- Foreign Keys (FK): UserID -> Users(UserID)  
--- Attributes:  
--  - Name (NVARCHAR(100), NOT NULL  
--  - Mass (DECIMAL(30,10))  
--  - Diameter (DECIMAL(20,10))  
--  - Gravity (DECIMAL(10,4))  
--  - OrbitalPeriod (DECIMAL(15,5))  
--  - Description (NVARCHAR(MAX))  
--  - CreatedAt (DATETIME2, DEFAULT: GETDATE())  
--  - UpdatedAt (DATETIME2)  

--------------------------------------------------------------------------------

-- 7. UserPlanetVisibility Table  
--- Primary Key (PK): VisibilityID  
--- Foreign Keys (FK):  
--  - UserPlanetID -> UserPlanets(UserPlanetID)  
--  - FriendID -> Users(UserID)  
--- Attributes:  
--  - CanView (BIT, DEFAULT: 0)  

--------------------------------------------------------------------------------

-- Relationships Between Tables  
-- 1. Users <-> UserProfiles:  
--   - One-to-One (One user has one profile).  

-- 2. Users <-> Friends:  
--   - Many-to-Many (Users can have multiple friends via the Friends table).  

-- 3. Users <-> CelestialBodies:  
--   - One-to-Many (A user can create multiple celestial bodies via CreatedByUserID).  

-- 4. Users <-> UserNotes:  
--   - One-to-Many (A user can write multiple notes).  

-- 5. CelestialBodies <-> UserNotes:  
--   - One-to-Many (A celestial body can have multiple notes).  

-- 6. Users <-> UserPlanets:  
--   - One-to-Many (A user can create multiple custom planets).  

-- 7. UserPlanets <-> UserPlanetVisibility:  
--   - Many-to-Many (A custom planet can be visible to multiple friends, and a friend can view multiple planets).  

----------------------------------- DATABASE QUERIES START HERE -----------------------------------

CREATE DATABASE Celestia;
USE Celestia;

-- Create Users table
CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Username NVARCHAR(50) NOT NULL UNIQUE,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    CreatedAt DATETIME2 DEFAULT GETDATE()
);

-- Create UserProfiles table
CREATE TABLE UserProfiles (
    ProfileID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL FOREIGN KEY REFERENCES Users(UserID),
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Bio NVARCHAR(500),
);

-- Create Friends table for managing user friendships
CREATE TABLE Friends (
    FriendshipID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL FOREIGN KEY REFERENCES Users(UserID),
    FriendID INT NOT NULL FOREIGN KEY REFERENCES Users(UserID),
    Status NVARCHAR(20) CHECK (Status IN ('Pending', 'Accepted', 'Rejected')),
    RequestedAt DATETIME2 DEFAULT GETDATE(),
    RespondedAt DATETIME2
);

-- Create CelestialBodies table for storing celestial data
CREATE TABLE CelestialBodies (
    BodyID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Type NVARCHAR(50) CHECK (Type IN ('Planet', 'Star', 'Moon', 'Asteroid', 'Comet', 'Dwarf Planet')),
    Mass DECIMAL(30,10),
    Diameter DECIMAL(20,10),
    Gravity DECIMAL(10,4),
    OrbitalPeriod DECIMAL(15,5),
    Description NVARCHAR(MAX),
    DiscoveredBy NVARCHAR(100),
    DiscoveryDate DATE,
    CreatedByUserID INT FOREIGN KEY REFERENCES Users(UserID)
);

-- Create UserNotes table for storing user notes on celestial bodies
CREATE TABLE UserNotes (
    NoteID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL FOREIGN KEY REFERENCES Users(UserID),
    BodyID INT NOT NULL FOREIGN KEY REFERENCES CelestialBodies(BodyID),
    NoteText NVARCHAR(MAX),
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2
);

-- Create UserPlanets table for storing user-created custom planets
CREATE TABLE UserPlanets (
    UserPlanetID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL FOREIGN KEY REFERENCES Users(UserID),
    Name NVARCHAR(100) NOT NULL,
    Mass DECIMAL(30,10),
    Diameter DECIMAL(20,10),
    Gravity DECIMAL(10,4),
    OrbitalPeriod DECIMAL(15,5),
    Description NVARCHAR(MAX),
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2
);

-- Create UserPlanetVisibility table to manage visibility of user-created planets to friends
CREATE TABLE UserPlanetVisibility (
    VisibilityID INT IDENTITY(1,1) PRIMARY KEY,
    UserPlanetID INT NOT NULL FOREIGN KEY REFERENCES UserPlanets(UserPlanetID),
    FriendID INT NOT NULL FOREIGN KEY REFERENCES Users(UserID),
    CanView BIT DEFAULT 0
);