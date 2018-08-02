/************************************************************/
/*****              Sql_SCRIPT :: HvP__ad              *****/
/*****                v00.300 - 2017.01.18               *****/
/*****                                                  *****/
/*****                                                  *****/
/*****    Some little explanation                       *****/
/*****        and a bit more of explanation            *****/
/*****        and even a little more                    *****/
/*****                                                  *****/
/************************************************************/

/************  TABLE & SEQUENCE  Users___ID + Users   ****************/
/*CREATE SEQUENCE [dbo].[Users]
    AS BIGINT
      START WITH 1000
      INCREMENT BY 1
    GO*/

CREATE TABLE [dbo].[Users]  (
      [userID] [BIGINT] IDENTITY(1,1)  NOT NULL,
      [username] [nvarchar](50) NOT NULL,
      [pass] [nvarchar](32) NOT NULL,
      [passTrap] [nvarchar](32),
      [type] [int] NOT NULL, -- 0 is normal user 1 is expert user
      [email] [nvarchar](100),
      [creationTimestamp] [datetime]  NOT NULL
      )
      ALTER TABLE [dbo].[Users] ADD CONSTRAINT [PK_dbo_Users] PRIMARY KEY ([userID]);
      ALTER TABLE [dbo].[Users] ADD CONSTRAINT [AK_dbo_Users_UNIQUE] UNIQUE ([username]);
      ALTER TABLE [dbo].[Users] ADD DEFAULT 0 FOR [type];
      ALTER TABLE [dbo].[Users] ADD DEFAULT GETUTCDATE() FOR [creationTimestamp];
  GO

CREATE TABLE [dbo].[Ratings]  (
      [ratingID] [BIGINT] IDENTITY(1,1)  NOT NULL,
      [userID] [BIGINT] NOT NULL,
      [value] [INT] NOT NULL,
      [creationTimestamp] DATE
      )
      ALTER TABLE [dbo].[Ratings] ADD CONSTRAINT [PK_dbo_Ratings] PRIMARY KEY ([ratingID]);
      ALTER TABLE [dbo].[Ratings] ADD FOREIGN KEY (userID) REFERENCES Users(userID);
      ALTER TABLE [dbo].[Ratings] ADD DEFAULT GETUTCDATE() FOR [creationTimestamp];
  GO

CREATE TABLE [dbo].[Notes]  (
      [noteID] [BIGINT] IDENTITY(1,1)  NOT NULL,
      [userID] [BIGINT] NOT NULL,
      [noteText] NVARCHAR(MAX) NOT NULL,
      [byUserID] [BIGINT] NULL,
      [creationTimestamp] DATE
      )
      ALTER TABLE [dbo].[Notes] ADD CONSTRAINT [PK_dbo_Notes] PRIMARY KEY ([noteID]);
      ALTER TABLE [dbo].[Notes] ADD FOREIGN KEY (userID) REFERENCES Users(userID);
      ALTER TABLE [dbo].[Notes] ADD FOREIGN KEY (byUserID) REFERENCES Users(userID);
      ALTER TABLE [dbo].[Notes] ADD DEFAULT GETUTCDATE() FOR [creationTimestamp];
  GO

CREATE TABLE [dbo].[Chats]  (
      [chatID] [BIGINT] IDENTITY(1,1)  NOT NULL,
      [isClosed] [BIT] NOT NULL,
      [user] [BIGINT] NOT NULL,
      [userExpert] [BIGINT] NOT NULL,
      [username] [nvarchar](50) NOT NULL,
      [usernameExpert] [nvarchar](50) NOT NULL,
      [creationTimestamp] [datetime]  NOT NULL
      )
      ALTER TABLE [dbo].[Chats] ADD CONSTRAINT [PK_dbo_Chat] PRIMARY KEY ([chatID]);
      ALTER TABLE [dbo].[Chats] ADD DEFAULT 0 FOR [isClosed];
      ALTER TABLE [dbo].[Chats] ADD DEFAULT GETUTCDATE() FOR [creationTimestamp];
  GO

CREATE TABLE [dbo].[Messages]  (
      [messageID] [BIGINT] IDENTITY(1,1)  NOT NULL,
      [chatID] [BIGINT] NOT NULL,
      [userID] [BIGINT] NOT NULL,
      [message] [NVARCHAR](MAX),
      [sendTimestamp] [NVARCHAR](50),
      [creationTimestamp] [datetime]  NOT NULL
      )
      ALTER TABLE [dbo].[Messages] ADD CONSTRAINT [PK_dbo_Messages] PRIMARY KEY ([messageID]);
      ALTER TABLE [dbo].[Messages] ADD DEFAULT GETUTCDATE() FOR [_timestamp];
      ALTER TABLE [dbo].[Messages] ADD FOREIGN KEY (userID) REFERENCES Users(userID);
      ALTER TABLE [dbo].[Messages] ADD FOREIGN KEY (chatID) REFERENCES Chats(chatID);
  GO
  --
  -- CREATE TABLE [dbo].[usersChats]  (
  --       [ID] [BIGINT] IDENTITY(1,1)  NOT NULL,
  --       [chatID] [BIGINT] IDENTITY(1,1)  NOT NULL,
  --       [userID] [BIGINT] NOT NULL,
  --       [creationTimestamp] [datetime]  NOT NULL
  --       )
  --       ALTER TABLE [dbo].[usersChats] ADD CONSTRAINT [PK_dbo_usersChats] PRIMARY KEY ([ID]);
  --       ALTER TABLE [dbo].[usersChats] ADD DEFAULT GETUTCDATE() FOR [creationTimestamp];
  --   GO

/************************************************************/
/*****         END  Sql_SCRIPT :: HvP__ad               *****/
/************************************************************/
