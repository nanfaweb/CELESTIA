-- SQLBook: Code
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

select * from CelestialBodies

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

select TOP 1 * from UserNotes

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
    CONSTRAINT UQ_PlanetVisibility UNIQUE (UserPlanetID, FriendID),
    -- Add constraint to check that user creating this visibility record
    -- has an accepted friendship with the FriendID
    CONSTRAINT CHK_ValidFriendship CHECK (
        EXISTS (
            SELECT 1 FROM Friends F
            JOIN UserPlanets UP ON F.UserID = UP.UserID 
            WHERE UP.UserPlanetID = UserPlanetVisibility.UserPlanetID
            AND F.FriendID = UserPlanetVisibility.FriendID
            AND F.Status = 'Accepted'
        )
    )
);
GO

----- VIEWS -----

CREATE VIEW ValidFriends AS
SELECT 
    UserID, 
    FriendID
FROM 
    Friends
WHERE 
    Status = 'Accepted';
GO


---- Procedures -----

CREATE PROCEDURE GrantPlanetVisibility
    @UserPlanetID INT,
    @FriendID INT,
    @CanView BIT = 1
AS
BEGIN
    -- Check if this is a valid friendship
    IF EXISTS (
        SELECT 1 FROM Friends F
        JOIN UserPlanets UP ON F.UserID = UP.UserID 
        WHERE UP.UserPlanetID = @UserPlanetID
        AND F.FriendID = @FriendID
        AND F.Status = 'Accepted'
    )
    BEGIN
        -- Insert or update visibility record
        MERGE UserPlanetVisibility AS target
        USING (SELECT @UserPlanetID, @FriendID, @CanView) AS source (UserPlanetID, FriendID, CanView)
        ON (target.UserPlanetID = source.UserPlanetID AND target.FriendID = source.FriendID)
        WHEN MATCHED THEN
            UPDATE SET CanView = source.CanView
        WHEN NOT MATCHED THEN
            INSERT (UserPlanetID, FriendID, CanView)
            VALUES (source.UserPlanetID, source.FriendID, source.CanView);
            
        RETURN 0; -- Success
    END
    ELSE
    BEGIN
        RAISERROR('Cannot grant visibility: No accepted friendship exists between these users', 16, 1);
        RETURN 1; -- Error
    END
END;
GO

---- Functions -----

-- Function to check if a user can view a specific planet
CREATE FUNCTION CanUserViewPlanet(@UserID INT, @UserPlanetID INT)
RETURNS BIT
AS
BEGIN
    DECLARE @CanView BIT = 0;
    
    -- Check if the user owns the planet
    IF EXISTS (SELECT 1 FROM UserPlanets WHERE UserPlanetID = @UserPlanetID AND UserID = @UserID)
        SET @CanView = 1;
    -- Check if the user has been granted visibility
    ELSE IF EXISTS (
        SELECT 1 FROM UserPlanetVisibility V
        JOIN Friends F ON V.FriendID = @UserID
        JOIN UserPlanets P ON V.UserPlanetID = P.UserPlanetID AND F.UserID = P.UserID
        WHERE V.UserPlanetID = @UserPlanetID
        AND F.Status = 'Accepted'
        AND V.CanView = 1
    )
        SET @CanView = 1;
        
    RETURN @CanView;
END;
GO

----- INSERTING DUMMY DATA -----

-- Insert dummy data into the Users table
INSERT INTO Users (Username, Email, PasswordHash)
VALUES 
  ('Afnan', 'afnan@example.com', 'dummyhash1'),
  ('Saad', 'saad@example.com', 'dummyhash2'),
  ('Zuhair', 'zuhair@example.com', 'dummyhash3');
GO

INSERT INTO Users (Username, Email, PasswordHash)
VALUES ('Ihtesham', 'abnoc@gmail.com', 'abnoc@123')
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
  ('Sun', 'Star', 1989000000.00, 1391400.00, 274.0, 0.00, 'The star at the center of our solar system.', 'Ancient', '2000-01-01', 1),
  ('Mercury', 'Planet', 330.11, 4879.00, 3.7, 87.97, 'The smallest planet and closest to the Sun.', 'Ancient', '2000-01-01', 1),
  ('Venus', 'Planet', 4868.5, 12104.00, 8.87, 224.70, 'Second planet from the Sun, known for its thick, toxic atmosphere.', 'Ancient', '2000-01-01', 1),
  ('Earth', 'Planet', 5972.00, 12742.00, 9.81, 365.25, 'Our home planet.', 'Ancient', '2000-01-01', 1),
  ('Mars', 'Planet', 639.00, 6779.00, 3.71, 687.00, 'The Red Planet.', 'Ancient', '2000-01-01', 1),
  ('Jupiter', 'Planet', 189800.00, 139820.00, 24.79, 4331.00, 'The largest planet in our solar system.', 'Ancient', '2000-01-01', 1),
  ('Saturn', 'Planet', 56830.00, 116460.00, 10.44, 10747.00, 'Famous for its prominent ring system.', 'Ancient', '2000-01-01', 1),
  ('Uranus', 'Planet', 8681.00, 50724.00, 8.87, 30589.00, 'An ice giant with a blue-green color due to methane.', 'William Herschel', '1781-03-13', 1),
  ('Neptune', 'Planet', 10241.00, 49244.00, 11.15, 59800.00, 'The farthest known planet from the Sun.', 'Urbain Le Verrier', '1846-09-23', 1);

-- Insert data for 20 common exoplanets and their host stars
-- Corrected Exoplanets and Host Stars Data
INSERT INTO CelestialBodies 
  (Name, Type, Mass, Diameter, Gravity, OrbitalPeriod, Description, DiscoveredBy, DiscoveryDate, CreatedByUserID)
VALUES
  -- Exoplanets (Mass in solar masses, Diameter in km)
  ('Proxima Centauri b', 'Planet', 1.27, 12000.00, 11.15, 11.2, 'Closest known exoplanet to Earth.', 'Anglada-Escudé et al.', '2016-08-24', 1),
  ('Kepler-22b', 'Planet', 36.00, 24000.00, 9.8, 289.9, 'First planet discovered in the habitable zone of a Sun-like star.', 'Borucki et al.', '2011-12-05', 1),
  ('TRAPPIST-1e', 'Planet', 0.62, 11000.00, 9.3, 6.1, 'One of seven Earth-sized planets in the TRAPPIST-1 system.', 'Gillon et al.', '2017-02-22', 1),
  ('TRAPPIST-1f', 'Planet', 0.68, 12000.00, 9.4, 9.2, 'Potentially habitable exoplanet in the TRAPPIST-1 system.', 'Gillon et al.', '2017-02-22', 1),
  ('Kepler-452b', 'Planet', 5.00, 18000.00, 10.0, 384.8, 'A super-Earth in the habitable zone of a Sun-like star.', 'Jenkins et al.', '2015-07-23', 1),
  ('HD 209458 b', 'Planet', 220.00, 143000.00, 9.4, 3.5, 'First exoplanet observed transiting its host star.', 'Charbonneau et al.', '1999-11-05', 1),
  ('51 Pegasi b', 'Planet', 150.00, 138000.00, 8.9, 4.2, 'First exoplanet discovered orbiting a Sun-like star.', 'Mayor and Queloz', '1995-10-06', 1),
  ('WASP-12b', 'Planet', 450.00, 190000.00, 8.1, 1.1, 'A hot Jupiter with a very short orbital period.', 'Hebb et al.', '2008-04-01', 1),
  ('GJ 1214 b', 'Planet', 6.55, 40000.00, 7.9, 1.6, 'A water-rich super-Earth.', 'Charbonneau et al.', '2009-12-16', 1),
  ('LHS 1140 b', 'Planet', 6.98, 18000.00, 10.5, 24.7, 'A rocky super-Earth in the habitable zone.', 'Dittmann et al.', '2017-04-19', 1),

  -- Host Stars (Mass in Solar masses, Diameter in km)
  ('Proxima Centauri', 'Star', 0.122, 200000.00, 274.0, 230000000.0, 'Closest star to the Sun.', 'Ancient', '1915-01-01', 1),
  ('Kepler-22', 'Star', 0.97, 1391400.00, 260.0, 250000000.0, 'Host star of Kepler-22b.', 'Borucki et al.', '2009-05-12', 1),
  ('TRAPPIST-1', 'Star', 0.089, 116000.00, 150.0, 270000000.0, 'Host star of the TRAPPIST-1 planetary system.', 'Gillon et al.', '1999-01-01', 1),
  ('Kepler-452', 'Star', 1.04, 1392000.00, 280.0, 300000000.0, 'Host star of Kepler-452b.', 'Jenkins et al.', '2009-05-12', 1),
  ('HD 209458', 'Star', 1.15, 1470000.00, 300.0, 320000000.0, 'Host star of HD 209458 b.', 'Charbonneau et al.', '1999-11-05', 1),
  ('51 Pegasi', 'Star', 1.06, 1430000.00, 290.0, 340000000.0, 'Host star of 51 Pegasi b.', 'Mayor and Queloz', '1995-10-06', 1),
  ('WASP-12', 'Star', 1.35, 1900000.00, 310.0, 360000000.0, 'Host star of WASP-12b.', 'Hebb et al.', '2008-04-01', 1),
  ('GJ 1214', 'Star', 0.157, 200000.00, 200.0, 380000000.0, 'Host star of GJ 1214 b.', 'Charbonneau et al.', '2009-12-16', 1),
  ('LHS 1140', 'Star', 0.15, 180000.00, 180.0, 400000000.0, 'Host star of LHS 1140 b.', 'Dittmann et al.', '2017-04-19', 1);

-- Delete old exoplanets and host stars from the CelestialBodies table
DELETE FROM CelestialBodies
WHERE Name IN (
    -- Exoplanets
    'Proxima Centauri b', 'Kepler-22b', 'TRAPPIST-1e', 'TRAPPIST-1f', 'Kepler-452b',
    'HD 209458 b', '51 Pegasi b', 'WASP-12b', 'GJ 1214 b', 'LHS 1140 b',
    -- Host Stars
    'Proxima Centauri', 'Kepler-22', 'TRAPPIST-1', 'Kepler-452', 'HD 209458',
    '51 Pegasi', 'WASP-12', 'GJ 1214', 'LHS 1140'
);

-- Verify the deletion
SELECT * FROM CelestialBodies;

SELECT * FROM CelestialBodies;
select * from UserNotes

-- Insert dummy data into the UserNotes table
-- Make sure the BodyIDs (1 and 2) exist from the CelestialBodies insertion
INSERT INTO UserNotes (UserID, BodyID, NoteText)
VALUES
  (1, 4, 'Earth is our beautiful home.'),
  (2, 5, 'Mars is fascinating.');
GO

SELECT BodyID, Name FROM CelestialBodies;

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