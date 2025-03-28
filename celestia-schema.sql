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
go

USE Celestia;
GO

-- Create Users table
CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Username NVARCHAR(50) NOT NULL UNIQUE,
    Email NVARCHAR(100) NOT NULL UNIQUE CHECK (Email LIKE '%_@__%.__%'), -- Basic email format validation
    PasswordHash NVARCHAR(255) NOT NULL 
        CHECK (
            LEN(PasswordHash) >= 8 AND                   -- At least 8 characters
            PasswordHash LIKE '%[A-Z]%' AND              -- At least one uppercase letter
            PasswordHash LIKE '%[a-z]%' AND              -- At least one lowercase letter
            PasswordHash LIKE '%[!@#$%^&*()_+\-=\[\]{};'':"\\|,.<>\/?]%'  -- At least one special character
        ),
    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE() -- Ensure timestamp is never null
);
GO

-- Create UserProfiles table
CREATE TABLE UserProfiles (
    ProfileID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL FOREIGN KEY REFERENCES Users(UserID) ON DELETE CASCADE,
    FirstName NVARCHAR(50) NOT NULL DEFAULT '',
    LastName NVARCHAR(50) NOT NULL DEFAULT '',
    Bio NVARCHAR(500) NOT NULL DEFAULT ''
);
GO

-- Create Friends table for managing user friendships
CREATE TABLE Friends (
    FriendshipID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL FOREIGN KEY REFERENCES Users(UserID) ON DELETE CASCADE,
    FriendID INT NOT NULL FOREIGN KEY REFERENCES Users(UserID) ON DELETE CASCADE,
    Status NVARCHAR(20) NOT NULL CHECK (Status IN ('Pending', 'Accepted', 'Rejected')),
    RequestedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
    RespondedAt DATETIME2,
    -- Prevent self-friendship
    CONSTRAINT CHK_NoSelfFriendship CHECK (UserID <> FriendID),
    -- Ensure unique friendships (prevent duplicates)
    CONSTRAINT UQ_Friendship UNIQUE (UserID, FriendID)
);
GO

-- Create CelestialBodies table for storing celestial data
CREATE TABLE CelestialBodies (
    BodyID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL CHECK (LEN(TRIM(Name)) > 0),
    Type NVARCHAR(50) NOT NULL CHECK (Type IN ('Planet', 'Star', 'Moon', 'Asteroid', 'Comet', 'Dwarf Planet')),
    Mass DECIMAL(30,10) CHECK (Mass > 0),
    Diameter DECIMAL(20,10) CHECK (Diameter > 0),
    Gravity DECIMAL(10,4) CHECK (Gravity >= 0),
    OrbitalPeriod DECIMAL(15,5) CHECK (OrbitalPeriod >= 0),
    Description NVARCHAR(MAX) NOT NULL DEFAULT '',
    DiscoveredBy NVARCHAR(100) NOT NULL DEFAULT '',
    DiscoveryDate DATE CHECK (DiscoveryDate <= GETDATE()),
    CreatedByUserID INT NOT NULL FOREIGN KEY REFERENCES Users(UserID) ON DELETE CASCADE,
    -- Ensure name uniqueness per celestial type
    CONSTRAINT UQ_CelestialBodyName UNIQUE (Name, Type)
);
GO

-- Create UserNotes table for storing user notes on celestial bodies
CREATE TABLE UserNotes (
    NoteID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL FOREIGN KEY REFERENCES Users(UserID) ON DELETE CASCADE,
    BodyID INT NOT NULL FOREIGN KEY REFERENCES CelestialBodies(BodyID) ON DELETE CASCADE,
    NoteText NVARCHAR(MAX) NOT NULL CHECK (LEN(TRIM(NoteText)) > 0),
    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME2,
    -- Ensure UpdatedAt is after CreatedAt
    CONSTRAINT CHK_NotesDateValid CHECK (UpdatedAt IS NULL OR UpdatedAt >= CreatedAt)
);
GO

-- Create UserPlanets table for storing user-created custom planets
CREATE TABLE UserPlanets (
    UserPlanetID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL FOREIGN KEY REFERENCES Users(UserID) ON DELETE CASCADE,
    Name NVARCHAR(100) NOT NULL CHECK (LEN(TRIM(Name)) > 0),
    Mass DECIMAL(30,10) CHECK (Mass > 0),
    Diameter DECIMAL(20,10) CHECK (Diameter > 0),
    Gravity DECIMAL(10,4) CHECK (Gravity >= 0),
    OrbitalPeriod DECIMAL(15,5) CHECK (OrbitalPeriod >= 0),
    Description NVARCHAR(MAX) NOT NULL DEFAULT '',
    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME2,
    -- Ensure UpdatedAt is after CreatedAt
    CONSTRAINT CHK_PlanetDateValid CHECK (UpdatedAt IS NULL OR UpdatedAt >= CreatedAt),
    -- Ensure unique planet names per user
    CONSTRAINT UQ_UserPlanetName UNIQUE (UserID, Name)
);
GO

-- Create UserPlanetVisibility table to manage visibility of user-created planets to friends
CREATE TABLE UserPlanetVisibility (
    VisibilityID INT IDENTITY(1,1) PRIMARY KEY,
    UserPlanetID INT NOT NULL FOREIGN KEY REFERENCES UserPlanets(UserPlanetID) ON DELETE CASCADE,
    FriendID INT NOT NULL FOREIGN KEY REFERENCES Users(UserID) ON DELETE CASCADE,
    CanView BIT NOT NULL DEFAULT 0,
    -- Ensure unique visibility entry per planet-friend pair
    CONSTRAINT UQ_PlanetVisibility UNIQUE (UserPlanetID, FriendID)
);
GO

----- INSERTING DUMMY DATA -----

-- Insert dummy data into the Users table
INSERT INTO Users (Username, Email, PasswordHash)
VALUES 
  ('Afnan', 'afnan@example.com', 'dummyhash1'),
  ('Saad', 'saad@example.com', 'dummyhash2'),
  ('Zuhair', 'zuhair@example.com', 'dummyhash3');
GO

select * from users

-- Insert dummy data into the UserProfiles table
-- Assuming UserIDs 1, 2, 3 exist from the previous insertion
INSERT INTO UserProfiles (UserID, FirstName, LastName, Bio)
VALUES 
  (1, 'Afnan', 'Asif', 'Bio for Afnan'),
  (2, 'Saad', 'Riaz', 'Bio for Saad'),
  (3, 'Zuhair', 'Ahmed', 'Bio for Zuhair');
GO

select * from UserProfiles

-- Insert dummy data into the Friends table
-- Example friendships among these users
INSERT INTO Friends (UserID, FriendID, Status, RequestedAt, RespondedAt)
VALUES 
  (1, 2, 'Accepted', GETDATE(), GETDATE()),
  (2, 3, 'Pending', GETDATE(), NULL),
  (1, 3, 'Rejected', GETDATE(), GETDATE());
GO

select * from Friends

-- Insert dummy data into the CelestialBodies table
-- Note: Reduced numeric values to avoid overflow (e.g., using e20 instead of e24)
INSERT INTO CelestialBodies 
  (Name, Type, Mass, Diameter, Gravity, OrbitalPeriod, Description, DiscoveredBy, DiscoveryDate, CreatedByUserID)
VALUES
  ('Earth', 'Planet', 5972000.00, 12742.00, 9.81, 365.25, 'Our home planet', 'Ancient', '2000-01-01', 1),
  ('Mars', 'Planet', 639000.00, 6779.00, 3.71, 687.00, 'The Red Planet', 'Ancient', '2000-01-01', 2);
GO

select * from CelestialBodies

-- Insert dummy data into the UserNotes table
-- Make sure the BodyIDs (1 and 2) exist from the CelestialBodies insertion
INSERT INTO UserNotes (UserID, BodyID, NoteText)
VALUES
  (1, 1, 'Earth is our beautiful home.'),
  (2, 2, 'Mars is fascinating.');
GO

select * from UserNotes

-- Insert dummy data into the UserPlanets table
-- Use lower numeric values for custom planets
INSERT INTO UserPlanets (UserID, Name, Mass, Diameter, Gravity, OrbitalPeriod, Description, CreatedAt)
VALUES 
  (1, 'Afnan Planet', 50000.00, 10000.00, 9.5, 400.00, 'Custom planet created by Afnan', GETDATE()),
  (2, 'Saad Planet', 48000.00, 9800.00, 9.2, 360.00, 'Custom planet created by Saad', GETDATE()),
  (3, 'Zuhair Planet', 52000.00, 10200.00, 9.8, 420.00, 'Custom planet created by Zuhair', GETDATE());
GO

select * from UserPlanets

-- Insert dummy data into the UserPlanetVisibility table
-- Ensure that the UserPlanetIDs (1, 2, 3) exist from the UserPlanets insertion.
INSERT INTO UserPlanetVisibility (UserPlanetID, FriendID, CanView)
VALUES 
  (1, 2, 1);  -- Afnan's planet visible to Saad
GO

select * from UserPlanetVisibility

--drop database Celestia
--use master