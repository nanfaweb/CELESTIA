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



--------------------------------------------------------------------------------
-- I. Views for Simplified Data Retrieval
--------------------------------------------------------------------------------

CREATE VIEW ValidFriends AS
SELECT 
    UserID, 
    FriendID
FROM 
    Friends
WHERE 
    Status = 'Accepted';
GO


-- View: Detailed User Profile Information
CREATE VIEW vw_UserProfileDetails AS
SELECT
    U.UserID,
    U.Username,
    U.Email,
    U.CreatedAt AS UserSince,
    P.ProfileID,
    P.FirstName,
    P.LastName,
    P.Bio
FROM Users U
JOIN UserProfiles P ON U.UserID = P.UserID;
GO

-- View: Accepted Friendships (Easier to Query Friend Lists)
CREATE VIEW vw_FriendList AS
SELECT
    F.UserID AS UserA_ID,
    U_A.Username AS UserA_Username,
    F.FriendID AS UserB_ID,
    U_B.Username AS UserB_Username,
    F.RequestedAt,
    F.RespondedAt AS FriendsSince
FROM Friends F
JOIN Users U_A ON F.UserID = U_A.UserID
JOIN Users U_B ON F.FriendID = U_B.UserID
WHERE F.Status = 'Accepted';
GO

-- View: Basic Celestial Body List
CREATE VIEW vw_CelestialBodySummary AS
SELECT
    BodyID,
    Name,
    Type,
    Mass,
    Diameter,
    CreatedByUserID
FROM CelestialBodies;
GO

-- View: User Planet Summary (Doesn't check visibility)
CREATE VIEW vw_UserPlanetSummary AS
SELECT
    UP.UserPlanetID,
    UP.Name,
    UP.Description,
    UP.CreatedAt,
    UP.UserID AS OwnerUserID,
    U.Username AS OwnerUsername
FROM UserPlanets UP
JOIN Users U ON UP.UserID = U.UserID;
GO


--------------------------------------------------------------------------------
-- II. Stored Procedures for Actions & Parameterized Queries
--------------------------------------------------------------------------------

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


-- SP: Check if Username or Email exists
CREATE PROCEDURE sp_CheckUserExistence
    @Username NVARCHAR(50),
    @Email NVARCHAR(100),
    @UserExists BIT OUTPUT -- Output Parameter
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM Users WHERE Username = @Username OR Email = @Email)
        SET @UserExists = 1;
    ELSE
        SET @UserExists = 0;
END;
GO

-- SP: Register a new user (Hashing MUST be done in app code)
CREATE PROCEDURE sp_RegisterUser
    @Username NVARCHAR(50),
    @Email NVARCHAR(100),
    @PasswordHash NVARCHAR(255), -- Pass the pre-hashed password
    @FirstName NVARCHAR(50) = '',
    @LastName NVARCHAR(50) = '',
    @Bio NVARCHAR(500) = '',
    @NewUserID INT OUTPUT -- Output Parameter
AS
BEGIN
    SET NOCOUNT ON;
    -- Check existence (optional redundancy if checked before calling)
    IF EXISTS (SELECT 1 FROM Users WHERE Username = @Username OR Email = @Email)
    BEGIN
        RAISERROR('Username or Email already exists.', 16, 1);
        SET @NewUserID = -1; -- Indicate failure
        RETURN 1;
    END

    -- REMOVE THE CHECK CONSTRAINT ON PasswordHash in table definition first!
    BEGIN TRY
        INSERT INTO Users (Username, Email, PasswordHash)
        VALUES (@Username, @Email, @PasswordHash);

        SET @NewUserID = SCOPE_IDENTITY();

        -- Create the corresponding profile
        INSERT INTO UserProfiles (UserID, FirstName, LastName, Bio)
        VALUES (@NewUserID, @FirstName, @LastName, @Bio);

        RETURN 0; -- Success
    END TRY
    BEGIN CATCH
        -- Basic error handling
        SET @NewUserID = -1;
        THROW; -- Rethrow the original error
        RETURN 1; -- Failure
    END CATCH
END;
GO

-- SP: Get User Info for Login Verification
CREATE PROCEDURE sp_GetUserForLogin
    @LoginIdentifier NVARCHAR(100) -- Can be Username or Email
AS
BEGIN
    SET NOCOUNT ON;
    SELECT UserID, PasswordHash FROM Users WHERE Username = @LoginIdentifier OR Email = @LoginIdentifier;
    -- Application code compares hashes
END;
GO

-- SP: Get User Profile Details by UserID
CREATE PROCEDURE sp_GetUserProfile
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM vw_UserProfileDetails WHERE UserID = @UserID;
END;
GO

-- SP: Update User Profile (by logged-in user)
CREATE PROCEDURE sp_UpdateMyProfile
    @AuthenticatedUserID INT,
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Bio NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE UserProfiles
    SET FirstName = @FirstName, LastName = @LastName, Bio = @Bio
    WHERE UserID = @AuthenticatedUserID;
END;
GO

-- SP: (Optional) Update User Email
CREATE PROCEDURE sp_UpdateMyEmail
    @AuthenticatedUserID INT,
    @NewEmail NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
     -- Check if new email already exists (excluding the current user)
    IF EXISTS (SELECT 1 FROM Users WHERE Email = @NewEmail AND UserID <> @AuthenticatedUserID)
    BEGIN
        RAISERROR('Email address already in use by another account.', 16, 1);
        RETURN 1;
    END

    UPDATE Users SET Email = @NewEmail WHERE UserID = @AuthenticatedUserID;
    RETURN 0;
END;
GO

-- SP: (Optional) Update User Password (Hashing done in app)
CREATE PROCEDURE sp_UpdateMyPassword
    @AuthenticatedUserID INT,
    @NewPasswordHash NVARCHAR(255) -- Pass the new, pre-hashed password
AS
BEGIN
    SET NOCOUNT ON;
    -- REMOVE THE CHECK CONSTRAINT ON PasswordHash in table definition first!
    UPDATE Users SET PasswordHash = @NewPasswordHash WHERE UserID = @AuthenticatedUserID;
END;
GO

-- SP: Search for potential friends
CREATE PROCEDURE sp_SearchUsers
    @SearchQuery NVARCHAR(50),
    @RequesterUserID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT UserID, Username
    FROM Users
    WHERE Username LIKE @SearchQuery + '%' AND UserID <> @RequesterUserID;
END;
GO

-- SP: Send Friend Request
CREATE PROCEDURE sp_SendFriendRequest
    @RequesterUserID INT,
    @TargetUserID INT
AS
BEGIN
    SET NOCOUNT ON;
    IF @RequesterUserID = @TargetUserID
    BEGIN
        RAISERROR('Cannot send a friend request to yourself.', 16, 1);
        RETURN 1;
    END

    -- Check if already friends or pending request exists
    IF EXISTS (
        SELECT 1 FROM Friends
        WHERE (UserID = @RequesterUserID AND FriendID = @TargetUserID)
           OR (UserID = @TargetUserID AND FriendID = @RequesterUserID)
    )
    BEGIN
        RAISERROR('Friendship already exists or request is pending.', 16, 1);
        RETURN 1;
    END

    INSERT INTO Friends (UserID, FriendID, Status)
    VALUES (@RequesterUserID, @TargetUserID, 'Pending');
    RETURN 0; -- Success
END;
GO

-- SP: Check Friendship Status
CREATE PROCEDURE sp_CheckFriendshipStatus
    @UserA_ID INT,
    @UserB_ID INT,
    @Status NVARCHAR(20) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT @Status = Status
    FROM Friends
    WHERE (UserID = @UserA_ID AND FriendID = @UserB_ID) OR (UserID = @UserB_ID AND FriendID = @UserA_ID);

    IF @Status IS NULL SET @Status = 'None'; -- No record found
END;
GO


-- SP: Respond to Friend Request (Accept/Reject)
CREATE PROCEDURE sp_RespondToFriendRequest
    @RecipientUserID INT, -- The user accepting/rejecting
    @RequesterUserID INT, -- The user who sent the request
    @ResponseAction NVARCHAR(10) -- 'Accept' or 'Reject'
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @NewStatus NVARCHAR(20);

    IF @ResponseAction = 'Accept'
        SET @NewStatus = 'Accepted';
    ELSE IF @ResponseAction = 'Reject'
        SET @NewStatus = 'Rejected';
    ELSE
    BEGIN
        RAISERROR('Invalid ResponseAction. Must be ''Accept'' or ''Reject''.', 16, 1);
        RETURN 1;
    END

    -- Ensure the request exists and is pending, and directed to the recipient
    IF NOT EXISTS (
        SELECT 1 FROM Friends
        WHERE UserID = @RequesterUserID AND FriendID = @RecipientUserID AND Status = 'Pending'
    )
    BEGIN
        RAISERROR('No pending friend request found from this user to you.', 16, 1);
        RETURN 1;
    END

    BEGIN TRANSACTION;
    BEGIN TRY
        -- Update the original request
        UPDATE Friends
        SET Status = @NewStatus, RespondedAt = GETDATE()
        WHERE UserID = @RequesterUserID AND FriendID = @RecipientUserID AND Status = 'Pending';

        -- If accepted, create the reciprocal relationship
        IF @NewStatus = 'Accepted'
        BEGIN
             -- Double-check if reciprocal already exists (shouldn't if logic is correct)
             IF NOT EXISTS (SELECT 1 FROM Friends WHERE UserID = @RecipientUserID AND FriendID = @RequesterUserID)
             BEGIN
                INSERT INTO Friends (UserID, FriendID, Status, RequestedAt, RespondedAt)
                SELECT FriendID, UserID, 'Accepted', RequestedAt, GETDATE()
                FROM Friends
                WHERE UserID = @RequesterUserID AND FriendID = @RecipientUserID; -- Get original timestamp
            END
        END

        COMMIT TRANSACTION;
        RETURN 0; -- Success
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW; -- Rethrow error
        RETURN 1; -- Failure
    END CATCH
END;
GO


-- SP: List Pending Incoming Friend Requests
CREATE PROCEDURE sp_GetPendingFriendRequests
    @AuthenticatedUserID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT F.FriendshipID, U.UserID AS RequesterID, U.Username AS RequesterUsername, F.RequestedAt
    FROM Friends F
    JOIN Users U ON F.UserID = U.UserID -- Requester info
    WHERE F.FriendID = @AuthenticatedUserID AND F.Status = 'Pending';
END;
GO

-- SP: List Accepted Friends (Using the View)
CREATE PROCEDURE sp_GetMyFriendList
    @AuthenticatedUserID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT V.UserB_ID AS FriendID, V.UserB_Username AS FriendUsername -- , Add profile fields if needed
    FROM vw_FriendList V
    WHERE V.UserA_ID = @AuthenticatedUserID
    ORDER BY FriendUsername;
    -- Optionally JOIN UserProfiles here if needed based on FriendID
END;
GO

-- SP: Remove Friend
CREATE PROCEDURE sp_RemoveFriend
    @AuthenticatedUserID INT,
    @FriendToRemoveID INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM Friends
    WHERE (UserID = @AuthenticatedUserID AND FriendID = @FriendToRemoveID)
       OR (UserID = @FriendToRemoveID AND FriendID = @AuthenticatedUserID);
END;
GO


-- SP: Add New Celestial Body (Admin Action Likely)
CREATE PROCEDURE sp_AddCelestialBody
    @Name NVARCHAR(100),
    @Type NVARCHAR(50),
    @Mass DECIMAL(30,10) = NULL,
    @Diameter DECIMAL(20,10) = NULL,
    @Gravity DECIMAL(10,4) = NULL,
    @OrbitalPeriod DECIMAL(15,5) = NULL,
    @Description NVARCHAR(MAX) = '',
    @DiscoveredBy NVARCHAR(100) = '',
    @DiscoveryDate DATE = NULL,
    @AdminUserID INT -- ID of user adding it
AS
BEGIN
    SET NOCOUNT ON;
     -- Unique constraint handles duplicate Name/Type pairs
    INSERT INTO CelestialBodies
      (Name, Type, Mass, Diameter, Gravity, OrbitalPeriod, Description, DiscoveredBy, DiscoveryDate, CreatedByUserID)
    VALUES
      (@Name, @Type, @Mass, @Diameter, @Gravity, @OrbitalPeriod, @Description, @DiscoveredBy, @DiscoveryDate, @AdminUserID);
END;
GO

-- SP: Get Celestial Body Details by ID
CREATE PROCEDURE sp_GetCelestialBodyByID
    @BodyID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM vw_CelestialBodySummary WHERE BodyID = @BodyID; -- Or Select all columns from base table if needed
    -- If full details needed: SELECT * FROM CelestialBodies WHERE BodyID = @BodyID;
END;
GO

-- SP: Get Celestial Body Details by Name/Type
CREATE PROCEDURE sp_GetCelestialBodyByNameType
    @Name NVARCHAR(100),
    @Type NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM CelestialBodies WHERE Name = @Name AND Type = @Type;
END;
GO

-- SP: List/Search Celestial Bodies
CREATE PROCEDURE sp_SearchCelestialBodies
    @FilterType NVARCHAR(50) = NULL, -- Optional Type filter
    @SearchName NVARCHAR(100) = NULL -- Optional Name fragment search
AS
BEGIN
    SET NOCOUNT ON;
    SELECT BodyID, Name, Type, Diameter, Mass
    FROM CelestialBodies
    WHERE (@FilterType IS NULL OR Type = @FilterType)
      AND (@SearchName IS NULL OR Name LIKE '%' + @SearchName + '%')
    ORDER BY Name;
END;
GO

-- SP: Update Celestial Body (Admin Action Likely)
CREATE PROCEDURE sp_UpdateCelestialBody
    @BodyID INT,
    @Name NVARCHAR(100),
    @Type NVARCHAR(50),
    @Mass DECIMAL(30,10) = NULL,
    @Diameter DECIMAL(20,10) = NULL,
    @Gravity DECIMAL(10,4) = NULL,
    @OrbitalPeriod DECIMAL(15,5) = NULL,
    @Description NVARCHAR(MAX),
    @DiscoveredBy NVARCHAR(100),
    @DiscoveryDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE CelestialBodies
    SET Name = @Name,
        Type = @Type,
        Mass = @Mass,
        Diameter = @Diameter,
        Gravity = @Gravity,
        OrbitalPeriod = @OrbitalPeriod,
        Description = @Description,
        DiscoveredBy = @DiscoveredBy,
        DiscoveryDate = @DiscoveryDate
    WHERE BodyID = @BodyID;
END;
GO


-- SP: Add a User Note
CREATE PROCEDURE sp_AddUserNote
    @AuthenticatedUserID INT,
    @BodyID INT,
    @NoteText NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO UserNotes (UserID, BodyID, NoteText, UpdatedAt) -- Set UpdatedAt initially
    VALUES (@AuthenticatedUserID, @BodyID, @NoteText, GETDATE());
END;
GO

-- SP: Get Notes for a Celestial Body
CREATE PROCEDURE sp_GetNotesForCelestialBody
    @BodyID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT N.NoteID, N.NoteText, N.CreatedAt, N.UpdatedAt, U.Username AS AuthorUsername, N.UserID AS AuthorID
    FROM UserNotes N
    JOIN Users U ON N.UserID = U.UserID
    WHERE N.BodyID = @BodyID
    ORDER BY N.CreatedAt DESC;
END;
GO

-- SP: Get All Notes Created by a User
CREATE PROCEDURE sp_GetMyNotes
    @AuthenticatedUserID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT N.NoteID, N.NoteText, N.CreatedAt, N.UpdatedAt, CB.Name AS BodyName, CB.Type AS BodyType, N.BodyID
    FROM UserNotes N
    JOIN CelestialBodies CB ON N.BodyID = CB.BodyID
    WHERE N.UserID = @AuthenticatedUserID
    ORDER BY N.UpdatedAt DESC, N.CreatedAt DESC;
END;
GO

-- SP: Get Specific User Note Details (App MUST verify ownership via UserID before showing)
CREATE PROCEDURE sp_GetUserNoteByID
    @NoteID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT NoteID, UserID, BodyID, NoteText, CreatedAt, UpdatedAt
    FROM UserNotes
    WHERE NoteID = @NoteID;
END;
GO


-- SP: Update a User Note
CREATE PROCEDURE sp_UpdateMyNote
    @AuthenticatedUserID INT,
    @NoteID INT,
    @NewNoteText NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE UserNotes
    SET NoteText = @NewNoteText, UpdatedAt = GETDATE()
    WHERE NoteID = @NoteID AND UserID = @AuthenticatedUserID; -- Ensure ownership
END;
GO

-- SP: Delete a User Note
CREATE PROCEDURE sp_DeleteMyNote
    @AuthenticatedUserID INT,
    @NoteID INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM UserNotes
    WHERE NoteID = @NoteID AND UserID = @AuthenticatedUserID; -- Ensure ownership
END;
GO


-- SP: Create a User Custom Planet
CREATE PROCEDURE sp_CreateUserPlanet
    @AuthenticatedUserID INT,
    @Name NVARCHAR(100),
    @Mass DECIMAL(30,10) = NULL,
    @Diameter DECIMAL(20,10) = NULL,
    @Gravity DECIMAL(10,4) = NULL,
    @OrbitalPeriod DECIMAL(15,5) = NULL,
    @Description NVARCHAR(MAX) = ''
AS
BEGIN
    SET NOCOUNT ON;
    -- Unique constraint UQ_UserPlanetName handles duplicate name check for this user
    INSERT INTO UserPlanets
      (UserID, Name, Mass, Diameter, Gravity, OrbitalPeriod, Description, UpdatedAt)
    VALUES
      (@AuthenticatedUserID, @Name, @Mass, @Diameter, @Gravity, @OrbitalPeriod, @Description, GETDATE());
END;
GO

-- SP: Get User's Own Custom Planets
CREATE PROCEDURE sp_GetMyUserPlanets
    @AuthenticatedUserID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT UserPlanetID, Name, Diameter, Mass, CreatedAt, UpdatedAt, Description
    FROM UserPlanets
    WHERE UserID = @AuthenticatedUserID
    ORDER BY CreatedAt DESC;
END;
GO

-- SP: Get Specific Custom Planet Details (checks visibility)
CREATE PROCEDURE sp_GetUserPlanetDetails
    @ViewerUserID INT,
    @TargetUserPlanetID INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @CanView BIT;
    SELECT @CanView = dbo.CanUserViewPlanet(@ViewerUserID, @TargetUserPlanetID);

    IF @CanView = 1
    BEGIN
        SELECT P.UserPlanetID, P.Name, P.Mass, P.Diameter, P.Gravity, P.OrbitalPeriod, P.Description, P.CreatedAt, P.UpdatedAt, U.Username AS OwnerUsername, P.UserID as OwnerUserID
        FROM UserPlanets P
        JOIN Users U ON P.UserID = U.UserID
        WHERE P.UserPlanetID = @TargetUserPlanetID;
    END
    ELSE
    BEGIN
         -- Return an empty result set or handle appropriately
         -- SELECT NULL AS UserPlanetID WHERE 1=0; -- Example of empty set
        RAISERROR('You do not have permission to view this planet.', 16, 1);
        RETURN 1;
    END
END;
GO


-- SP: Update a Custom Planet
CREATE PROCEDURE sp_UpdateMyUserPlanet
    @AuthenticatedUserID INT,
    @UserPlanetID INT,
    @Name NVARCHAR(100),
    @Mass DECIMAL(30,10) = NULL,
    @Diameter DECIMAL(20,10) = NULL,
    @Gravity DECIMAL(10,4) = NULL,
    @OrbitalPeriod DECIMAL(15,5) = NULL,
    @Description NVARCHAR(MAX) = ''
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE UserPlanets
    SET Name = @Name,
        Mass = @Mass,
        Diameter = @Diameter,
        Gravity = @Gravity,
        OrbitalPeriod = @OrbitalPeriod,
        Description = @Description,
        UpdatedAt = GETDATE()
    WHERE UserPlanetID = @UserPlanetID AND UserID = @AuthenticatedUserID; -- Ensure ownership
END;
GO

-- SP: Delete a Custom Planet
CREATE PROCEDURE sp_DeleteMyUserPlanet
    @AuthenticatedUserID INT,
    @UserPlanetID INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM UserPlanets
    WHERE UserPlanetID = @UserPlanetID AND UserID = @AuthenticatedUserID; -- Ensure ownership (Cascades delete Visibility)
END;
GO

-- SP: Grant or Revoke Planet Visibility to a Friend
-- (Modifies the original procedure for simplicity)
ALTER PROCEDURE GrantPlanetVisibility -- Use ALTER to modify existing
    @OwnerUserID INT, -- Add owner ID for verification
    @UserPlanetID INT,
    @FriendID INT,
    @CanView BIT -- 1 to grant/update, 0 to revoke/update
AS
BEGIN
    SET NOCOUNT ON;
    -- 1. Verify Ownership
    IF NOT EXISTS (SELECT 1 FROM UserPlanets WHERE UserPlanetID = @UserPlanetID AND UserID = @OwnerUserID)
    BEGIN
         RAISERROR('Permission denied: You do not own this planet.', 16, 1);
         RETURN 1;
    END

    -- 2. Check if they are accepted friends
    IF NOT EXISTS (
        SELECT 1 FROM Friends F
        WHERE F.UserID = @OwnerUserID
        AND F.FriendID = @FriendID
        AND F.Status = 'Accepted'
    )
    BEGIN
        RAISERROR('Cannot grant/revoke visibility: No accepted friendship exists with this user.', 16, 1);
        RETURN 1;
    END

    -- 3. Insert or update visibility record
    MERGE UserPlanetVisibility AS target
    USING (SELECT @UserPlanetID, @FriendID, @CanView) AS source (UserPlanetID, FriendID, CanView)
    ON (target.UserPlanetID = source.UserPlanetID AND target.FriendID = source.FriendID)
    WHEN MATCHED THEN
        UPDATE SET CanView = source.CanView
    WHEN NOT MATCHED THEN
        INSERT (UserPlanetID, FriendID, CanView)
        VALUES (source.UserPlanetID, source.FriendID, source.CanView);

    RETURN 0; -- Success
END;
GO

-- SP: Get Friends Who Can View My Specific Planet
CREATE PROCEDURE sp_GetMyPlanetViewers
    @AuthenticatedUserID INT,
    @TargetUserPlanetID INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Ensure the requestor owns the planet
    IF NOT EXISTS (SELECT 1 FROM UserPlanets WHERE UserPlanetID = @TargetUserPlanetID AND UserID = @AuthenticatedUserID)
    BEGIN
         RAISERROR('Permission denied: You do not own this planet.', 16, 1);
         RETURN 1;
    END

    SELECT U.UserID AS FriendUserID, U.Username AS FriendUsername
    FROM UserPlanetVisibility V
    JOIN Users U ON V.FriendID = U.UserID
    WHERE V.UserPlanetID = @TargetUserPlanetID AND V.CanView = 1;

END;
GO

-- SP: Get Custom Planets Shared With Me
CREATE PROCEDURE sp_GetPlanetsSharedWithMe
    @AuthenticatedUserID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT P.UserPlanetID, P.Name, P.Description, Owner.Username AS OwnerUsername, Owner.UserID as OwnerUserID
    FROM UserPlanetVisibility V
    JOIN UserPlanets P ON V.UserPlanetID = P.UserPlanetID
    JOIN Users Owner ON P.UserID = Owner.UserID -- Get owner info
    JOIN Friends F ON V.FriendID = @AuthenticatedUserID AND P.UserID = F.UserID -- Ensure they are still accepted friends
    WHERE V.FriendID = @AuthenticatedUserID AND V.CanView = 1 AND F.Status = 'Accepted'
    ORDER BY P.Name;
END;
GO

-- SP: Check Visibility Status for a Specific Planet/Friend Pair
CREATE PROCEDURE sp_CheckPlanetVisibilityStatus
    @TargetUserPlanetID INT,
    @TargetFriendID INT,
    @CanViewStatus BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT @CanViewStatus = CanView
    FROM UserPlanetVisibility
    WHERE UserPlanetID = @TargetUserPlanetID AND FriendID = @TargetFriendID;

    IF @CanViewStatus IS NULL SET @CanViewStatus = 0; -- Default to false if no record exists
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