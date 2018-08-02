
/************  PROCEDURE  login    ****************/
CREATE OR ALTER PROCEDURE [dbo].[login]
    @InputJSON NVARCHAR(MAX),
    @ReturnJSON NVARCHAR(MAX) output -- if needed
    AS

      --declaration of variables to form JSON
      DECLARE @apiVersion NVARCHAR(20) = '1.0';
      DECLARE @data NVARCHAR(MAX);
      DECLARE @StatusMESSAGE NVARCHAR(500);
      DECLARE @StatusCODE INT;
      DECLARE @ErrorStep NVARCHAR(200)='';
      DECLARE @params NVARCHAR(MAX);

      --declaration of variables
      DECLARE @ReturnCODE int = 200 -- Comentar posible valores: 200 ok, 202 acepted, 400 bad request, 401 unauthorized, 500 error
      DECLARE @isValidUser int
      DECLARE @isPassTrap int
      DECLARE @userName NVARCHAR(50)
      DECLARE @pass NVARCHAR(32)
      DECLARE @userID BIGINT
      DECLARE @passTrap NVARCHAR(32)
      DECLARE @havePassTrap BIT = 1;
      DECLARE @email NVARCHAR(50);

      IF ISJSON(@InputJSON) = 0
        BEGIN
          SET @StatusMESSAGE='Incorrect JSON';
          SET @ReturnCODE = 400;
          SET @StatusCODE = 400;
        END

      ELSE
        BEGIN

          SET @userName = JSON_VALUE(@InputJSON,'$.params.username');
          SET @pass = JSON_VALUE(@InputJSON,'$.params.pass');
          SELECT @passTrap = passTrap FROM Users WHERE username = @userName;
          IF (@passTrap IS NULL OR @passTrap = '')
            BEGIN
              SET @havePassTrap = 0;
            END

          -- execution
          BEGIN TRY
            BEGIN TRANSACTION

                  -- TODO UPDATE LOG
                     SELECT @userID = userID FROM Users WHERE username = @userName;
                     SELECT @email = email FROM Users WHERE username = @userName;
                     SET @isValidUser = (SELECT COUNT(*) FROM Users WHERE username = @userName AND pass = @pass)
                     SET @isPassTrap = (SELECT COUNT(*) FROM Users WHERE username = @userName AND passTrap = @pass)
                     SET @data = (SELECT @userName as [userName], @isPassTrap as [isPassTrap], @havePassTrap as [passTrap], @email as [email], @userID as [userID] ,@isValidUser as [isValidUser] FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
                     SET @StatusMESSAGE='OK';
                     SET @ReturnCODE = 200;
                     SET @StatusCODE = 200;


                COMMIT TRANSACTION
              END TRY

              BEGIN CATCH
                    IF @@TRANCOUNT > 0 ROLLBACK

                    -- TODO :: un mensaje de error , a log, tal y como esta en el example for sql code
                    SET @StatusMESSAGE = 'ERROR on:: ' + @ErrorStep
                                 + ' #:: ' + cast(ERROR_NUMBER() as varchar(20))
                                 + ' SEV:: ' + cast(ERROR_SEVERITY() as varchar(20))
                                 + ' LINE:: ' + cast(ERROR_LINE() as varchar(20))
                                 + ' MSG:: ' + ERROR_MESSAGE()
                                 + ' INTO:: ' + ERROR_PROCEDURE();
                    SET @ReturnCODE = 500;
                    SET @StatusCODE = 500;

          END CATCH
        END

      EXEC @ReturnJSON = [dbo].[HvJSON_build] @apiVersion,@data,@StatusCODE,@StatusMESSAGE,@params;
      SELECT @ReturnJSON AS [ReturnJSON];
      RETURN @ReturnCODE;

GO


/************  PROCEDURE  register    ****************/
CREATE OR ALTER PROCEDURE [dbo].[register]
    @InputJSON NVARCHAR(MAX),
    @ReturnJSON NVARCHAR(MAX) output -- if needed
    AS

      --declaration of variables to form JSON
      DECLARE @apiVersion NVARCHAR(20) = '1.0';
      DECLARE @data NVARCHAR(MAX);
      DECLARE @StatusMESSAGE NVARCHAR(500);
      DECLARE @StatusCODE INT;
      DECLARE @ErrorStep NVARCHAR(200)='';
      DECLARE @params NVARCHAR(MAX);

      --declaration of variables
      DECLARE @ReturnCODE int = 200 -- Comentar posible valores: 200 ok, 202 acepted, 400 bad request, 401 unauthorized, 500 error
      DECLARE @isValidUser int
      DECLARE @userName NVARCHAR(50)
      DECLARE @isExpert int
      DECLARE @pass NVARCHAR(32)
      DECLARE @email [nvarchar](100)

      IF ISJSON(@InputJSON) = 0
        BEGIN
          SET @StatusMESSAGE='Incorrect JSON';
          SET @ReturnCODE = 400;
          SET @StatusCODE = 400;
        END
      ELSE
        BEGIN

          SET @userName = JSON_VALUE(@InputJSON,'$.params.username');
          SET @pass = JSON_VALUE(@InputJSON,'$.params.pass');
          SET @email = JSON_VALUE(@InputJSON,'$.params.email');
          SET @isExpert = JSON_VALUE(@InputJSON,'$.params.isExpert');

          IF (@userName IS NULL OR @userName = '') OR (@pass IS NULL OR @pass = '')
            BEGIN
              SET @StatusMESSAGE='Insufficient parameters to register';
              SET @ReturnCODE = 400;
              SET @StatusCODE = 400;
            END
          ELSE IF (SELECT COUNT(*) FROM Users WHERE username = @userName) > 0
            BEGIN
              SET @StatusMESSAGE='This username already exist';
              SET @ReturnCODE = 400;
              SET @StatusCODE = 400;
            END
          ELSE
            BEGIN

            -- execution
            BEGIN TRY
              BEGIN TRANSACTION
              IF (@isExpert IS NOT NULL AND @isExpert != '')
                BEGIN


                  INSERT INTO Users
                    (username, pass, email, type)
                  VALUES
                    (@userName, @pass, @email, @isExpert)


                END
                ELSE IF (@email IS NOT NULL AND @email != '')
                  BEGIN


                    INSERT INTO Users
                      (username, pass, email)
                    VALUES
                      (@userName, @pass, @email)


                  END
                ELSE
                  BEGIN

                    INSERT INTO Users
                      (username, pass)
                    VALUES
                      (@userName, @pass)

                  END

                  SET @StatusMESSAGE='User created';
                  SET @ReturnCODE = 200;
                  SET @StatusCODE = 200;


                  COMMIT TRANSACTION
                END TRY

                BEGIN CATCH
                      IF @@TRANCOUNT > 0 ROLLBACK

                      -- TODO :: un mensaje de error , a log, tal y como esta en el example for sql code
                      SET @StatusMESSAGE = 'ERROR on:: ' + @ErrorStep
                                   + ' #:: ' + cast(ERROR_NUMBER() as varchar(20))
                                   + ' SEV:: ' + cast(ERROR_SEVERITY() as varchar(20))
                                   + ' LINE:: ' + cast(ERROR_LINE() as varchar(20))
                                   + ' MSG:: ' + ERROR_MESSAGE()
                                   + ' INTO:: ' + ERROR_PROCEDURE();
                      SET @ReturnCODE = 500;
                      SET @StatusCODE = 500;

            END CATCH
          END
        END

      EXEC @ReturnJSON = [dbo].[HvJSON_build] @apiVersion,@data,@StatusCODE,@StatusMESSAGE,@params;
      SELECT @ReturnJSON AS [ReturnJSON];
      RETURN @ReturnCODE;

GO

/************  PROCEDURE  register    ****************/
CREATE OR ALTER PROCEDURE [dbo].[modifyUser]
    @InputJSON NVARCHAR(MAX),
    @ReturnJSON NVARCHAR(MAX) output -- if needed
    AS

      --declaration of variables to form JSON
      DECLARE @apiVersion NVARCHAR(20) = '1.0';
      DECLARE @data NVARCHAR(MAX);
      DECLARE @StatusMESSAGE NVARCHAR(500);
      DECLARE @StatusCODE INT;
      DECLARE @ErrorStep NVARCHAR(200)='';
      DECLARE @params NVARCHAR(MAX);

      --declaration of variables
      DECLARE @ReturnCODE int = 200 -- Comentar posible valores: 200 ok, 202 acepted, 400 bad request, 401 unauthorized, 500 error
      DECLARE @userID BIGINT
      DECLARE @userName NVARCHAR(50)
      DECLARE @pass NVARCHAR(32)
      DECLARE @passTrap NVARCHAR(32)
      DECLARE @email [nvarchar](100)

      IF ISJSON(@InputJSON) = 0
        BEGIN
          SET @StatusMESSAGE='Incorrect JSON';
          SET @ReturnCODE = 400;
          SET @StatusCODE = 400;
        END
      ELSE
        BEGIN

          SET @userID = JSON_VALUE(@InputJSON,'$.params.userID');
          SET @userName = JSON_VALUE(@InputJSON,'$.params.username');
          SET @pass = JSON_VALUE(@InputJSON,'$.params.pass');
          SET @passTrap = JSON_VALUE(@InputJSON,'$.params.passTrap');
          SET @email = JSON_VALUE(@InputJSON,'$.params.email');

          IF (SELECT COUNT(*) FROM Users WHERE userID = @userID) = 0
            BEGIN
              SET @StatusMESSAGE='This userID dont exist';
              SET @ReturnCODE = 400;
              SET @StatusCODE = 400;
            END
          ELSE IF (SELECT COUNT(*) FROM Users WHERE username = @userName AND userID != @userID) > 0
            BEGIN
              SET @StatusMESSAGE='This username already exist';
              SET @ReturnCODE = 400;
              SET @StatusCODE = 400;
            END
          ELSE
            BEGIN

            -- execution
            BEGIN TRY
              BEGIN TRANSACTION

                IF (@userName IS NOT NULL AND @userName != '')
                  BEGIN

                    UPDATE Users
                    SET username = @username
                    WHERE userID = @userID

                    UPDATE Chats
                    SET username = @username
                    WHERE [user] = @userID

                    UPDATE Chats
                    SET username = @username
                    WHERE userExpert = @userID


                  END
                IF (@email IS NOT NULL AND @email != '')
                  BEGIN

                    UPDATE Users
                    SET email = @email
                    where userID = @userID


                  END
                IF (@pass IS NOT NULL AND @pass != '')
                  BEGIN

                    UPDATE Users
                    SET pass = @pass
                    where userID = @userID


                  END
                IF (@passTrap IS NOT NULL AND @passTrap != '')
                  BEGIN

                    UPDATE Users
                    SET passTrap = @passTrap
                    where userID = @userID


                  END

                  SET @StatusMESSAGE='User created';
                  SET @ReturnCODE = 200;
                  SET @StatusCODE = 200;


                  COMMIT TRANSACTION
                END TRY

                BEGIN CATCH
                      IF @@TRANCOUNT > 0 ROLLBACK

                      -- TODO :: un mensaje de error , a log, tal y como esta en el example for sql code
                      SET @StatusMESSAGE = 'ERROR on:: ' + @ErrorStep
                                   + ' #:: ' + cast(ERROR_NUMBER() as varchar(20))
                                   + ' SEV:: ' + cast(ERROR_SEVERITY() as varchar(20))
                                   + ' LINE:: ' + cast(ERROR_LINE() as varchar(20))
                                   + ' MSG:: ' + ERROR_MESSAGE()
                                   + ' INTO:: ' + ERROR_PROCEDURE();
                      SET @ReturnCODE = 500;
                      SET @StatusCODE = 500;

            END CATCH
          END
        END

      EXEC @ReturnJSON = [dbo].[HvJSON_build] @apiVersion,@data,@StatusCODE,@StatusMESSAGE,@params;
      SELECT @ReturnJSON AS [ReturnJSON];
      RETURN @ReturnCODE;

GO

/************  PROCEDURE  addPassTrack    ****************/
CREATE OR ALTER PROCEDURE [dbo].[addPassTrap]
    @InputJSON NVARCHAR(MAX),
    @ReturnJSON NVARCHAR(MAX) output -- if needed
    AS

      --declaration of variables to form JSON
      DECLARE @apiVersion NVARCHAR(20) = '1.0';
      DECLARE @data NVARCHAR(MAX);
      DECLARE @StatusMESSAGE NVARCHAR(500);
      DECLARE @StatusCODE INT;
      DECLARE @ErrorStep NVARCHAR(200)='';
      DECLARE @params NVARCHAR(MAX);

      --declaration of variables
      DECLARE @ReturnCODE int = 200 -- Comentar posible valores: 200 ok, 202 acepted, 400 bad request, 401 unauthorized, 500 error
      DECLARE @userID BIGINT
      DECLARE @passFalse NVARCHAR(32)

      IF ISJSON(@InputJSON) = 0
        BEGIN
          SET @StatusMESSAGE='Incorrect JSON';
          SET @ReturnCODE = 400;
          SET @StatusCODE = 400;
        END
      ELSE
        BEGIN

          SET @userID = JSON_VALUE(@InputJSON,'$.params.userID');
          SET @passFalse = JSON_VALUE(@InputJSON,'$.params.passFalse');


          IF (@userID IS NULL OR @userID = '') OR (@passFalse IS NULL OR @passFalse = '')
            BEGIN
              SET @StatusMESSAGE='Insufficient parameters to register';
              SET @ReturnCODE = 400;
              SET @StatusCODE = 400;
            END
          ELSE IF (SELECT COUNT(*) FROM Users WHERE userID = @userID) = 0
            BEGIN
              SET @StatusMESSAGE='This username dont exist';
              SET @ReturnCODE = 400;
              SET @StatusCODE = 400;
            END
          ELSE
            BEGIN

            -- execution
            BEGIN TRY
              BEGIN TRANSACTION


                  UPDATE Users
                  SET passTrap = @passFalse
                  WHERE userID = @userID;

                  SET @StatusMESSAGE='Update passTrap';
                  SET @ReturnCODE = 200;
                  SET @StatusCODE = 200;


                  COMMIT TRANSACTION
                END TRY

                BEGIN CATCH
                      IF @@TRANCOUNT > 0 ROLLBACK

                      -- TODO :: un mensaje de error , a log, tal y como esta en el example for sql code
                      SET @StatusMESSAGE = 'ERROR on:: ' + @ErrorStep
                                   + ' #:: ' + cast(ERROR_NUMBER() as varchar(20))
                                   + ' SEV:: ' + cast(ERROR_SEVERITY() as varchar(20))
                                   + ' LINE:: ' + cast(ERROR_LINE() as varchar(20))
                                   + ' MSG:: ' + ERROR_MESSAGE()
                                   + ' INTO:: ' + ERROR_PROCEDURE();
                      SET @ReturnCODE = 500;
                      SET @StatusCODE = 500;

            END CATCH
          END
        END

      EXEC @ReturnJSON = [dbo].[HvJSON_build] @apiVersion,@data,@StatusCODE,@StatusMESSAGE,@params;
      SELECT @ReturnJSON AS [ReturnJSON];
      RETURN @ReturnCODE;

GO

/************  PROCEDURE  addPassTrack    ****************/
CREATE OR ALTER PROCEDURE [dbo].[getUserLastMessages]
    @InputJSON NVARCHAR(MAX),
    @ReturnJSON NVARCHAR(MAX) output -- if needed
    AS

      --declaration of variables to form JSON
      DECLARE @apiVersion NVARCHAR(20) = '1.0';
      DECLARE @data NVARCHAR(MAX);
      DECLARE @StatusMESSAGE NVARCHAR(500);
      DECLARE @StatusCODE INT;
      DECLARE @ErrorStep NVARCHAR(200)='';
      DECLARE @params NVARCHAR(MAX);

      --declaration of variables
      DECLARE @ReturnCODE int = 200 -- Comentar posible valores: 200 ok, 202 acepted, 400 bad request, 401 unauthorized, 500 error
      DECLARE @userID BIGINT
      DECLARE @isExpert BIT

      IF ISJSON(@InputJSON) = 0
        BEGIN
          SET @StatusMESSAGE='Incorrect JSON';
          SET @ReturnCODE = 400;
          SET @StatusCODE = 400;
        END
      ELSE
        BEGIN

          SET @userID = JSON_VALUE(@InputJSON,'$.params.userID');
          SET @isExpert = JSON_VALUE(@InputJSON,'$.params.isExpert');


          IF (@userID IS NULL OR @userID = '')
            BEGIN
              SET @StatusMESSAGE='User cant be null';
              SET @ReturnCODE = 400;
              SET @StatusCODE = 400;
            END
          ELSE IF (SELECT COUNT(*) FROM Users WHERE userID = @userID) = 0
            BEGIN
              SET @StatusMESSAGE='This username dont exist';
              SET @ReturnCODE = 400;
              SET @StatusCODE = 400;
            END
          ELSE
            BEGIN

            -- execution
            BEGIN TRY
              BEGIN TRANSACTION


              IF @isExpert = 1
                BEGIN

                SET @data = (select (SELECT ms.messageID, ms.chatID, ms.message, ms.creationTimestamp, chat.username as [chatUsername], chat.[user] as [chatUserID]
                FROM Messages as ms
                INNER JOIN Chats as chat ON ms.chatID = chat.chatID AND chat.[userExpert] = @userID AND chat.isClosed = 0
                INNER JOIN
                  (
                      SELECT  chatID as chatID, MAX(creationTimestamp) as creationTimestamp, MAX(messageID) as messageID
                      FROM    Messages
                      GROUP BY chatID
                  ) as mensaje ON ms.messageID = mensaje.messageID ORDER BY ms.messageID DESC
                FOR JSON PATH) AS [listMessages] for json path,WITHOUT_ARRAY_WRAPPER );

                END
              ELSE
                BEGIN

                  SET @data = (select (SELECT ms.messageID, ms.chatID, ms.message, ms.creationTimestamp, chat.userExpert as [chatUserID], chat.usernameExpert as [chatUsername]
                  FROM Messages as ms
                  INNER JOIN Chats as chat ON ms.chatID = chat.chatID AND chat.[user] = @userID AND chat.isClosed = 0
                  INNER JOIN
                    (
                        SELECT  chatID as chatID, MAX(creationTimestamp) as creationTimestamp, MAX(messageID) as messageID
                        FROM    Messages
                        GROUP BY chatID
                    ) as mensaje ON ms.messageID = mensaje.messageID ORDER BY ms.messageID DESC
                  FOR JSON PATH) AS [listMessages] for json path,WITHOUT_ARRAY_WRAPPER );

                END



                  SET @StatusMESSAGE='OK';
                  SET @ReturnCODE = 200;
                  SET @StatusCODE = 200;


                  COMMIT TRANSACTION
                END TRY

                BEGIN CATCH
                      IF @@TRANCOUNT > 0 ROLLBACK

                      -- TODO :: un mensaje de error , a log, tal y como esta en el example for sql code
                      SET @StatusMESSAGE = 'ERROR on:: ' + @ErrorStep
                                   + ' #:: ' + cast(ERROR_NUMBER() as varchar(20))
                                   + ' SEV:: ' + cast(ERROR_SEVERITY() as varchar(20))
                                   + ' LINE:: ' + cast(ERROR_LINE() as varchar(20))
                                   + ' MSG:: ' + ERROR_MESSAGE()
                                   + ' INTO:: ' + ERROR_PROCEDURE();
                      SET @ReturnCODE = 500;
                      SET @StatusCODE = 500;

            END CATCH
          END
        END

      EXEC @ReturnJSON = [dbo].[HvJSON_build] @apiVersion,@data,@StatusCODE,@StatusMESSAGE,@params;
      SELECT @ReturnJSON AS [ReturnJSON];
      RETURN @ReturnCODE;

GO



/************  PROCEDURE  addPassTrack    ****************/
CREATE OR ALTER PROCEDURE [dbo].[getChat]
    @InputJSON NVARCHAR(MAX),
    @ReturnJSON NVARCHAR(MAX) output -- if needed
    AS

      --declaration of variables to form JSON
      DECLARE @apiVersion NVARCHAR(20) = '1.0';
      DECLARE @data NVARCHAR(MAX);
      DECLARE @StatusMESSAGE NVARCHAR(500);
      DECLARE @StatusCODE INT;
      DECLARE @ErrorStep NVARCHAR(200)='';
      DECLARE @params NVARCHAR(MAX);

      --declaration of variables
      DECLARE @ReturnCODE int = 200 -- Comentar posible valores: 200 ok, 202 acepted, 400 bad request, 401 unauthorized, 500 error
      DECLARE @chatID BIGINT
      DECLARE @userID BIGINT

      IF ISJSON(@InputJSON) = 0
        BEGIN
          SET @StatusMESSAGE='Incorrect JSON';
          SET @ReturnCODE = 400;
          SET @StatusCODE = 400;
        END
      ELSE
        BEGIN

          SET @chatID = JSON_VALUE(@InputJSON,'$.params.chatID');
          SET @userID = JSON_VALUE(@InputJSON,'$.params.userID');


          IF (@chatID IS NULL OR @chatID = '')
            BEGIN
              SET @StatusMESSAGE='Chat cant be null';
              SET @ReturnCODE = 400;
              SET @StatusCODE = 400;
            END
          ELSE IF (SELECT COUNT(*) FROM Chats WHERE chatID = @chatID AND isClosed = 0) = 0
            BEGIN
              SET @StatusMESSAGE='This chat dont exist';
              SET @ReturnCODE = 400;
              SET @StatusCODE = 400;
            END
          ELSE
            BEGIN

            -- execution
            BEGIN TRY
              BEGIN TRANSACTION

              DECLARE @userChatID BIGINT;


              IF (SELECT count(*) FROM Users WHERE userID = @userID AND type = 1) = 1
                BEGIN
                  SELECT @userChatID = [user] FROM Chats WHERE chatID = @chatID;
                END
              ELSE IF (SELECT count(*) FROM Users WHERE userID = @userID AND type = 0) = 1
                BEGIN
                    SELECT @userChatID = [userExpert] FROM Chats WHERE chatID = @chatID;
                END


                SET @data = (select (SELECT * FROM Messages WHERE chatID = @chatID FOR JSON PATH) AS [listMessages], @userChatID AS [userChatID] for json path,WITHOUT_ARRAY_WRAPPER );


                  SET @StatusMESSAGE='OK';
                  SET @ReturnCODE = 200;
                  SET @StatusCODE = 200;


                  COMMIT TRANSACTION
                END TRY

                BEGIN CATCH
                      IF @@TRANCOUNT > 0 ROLLBACK

                      -- TODO :: un mensaje de error , a log, tal y como esta en el example for sql code
                      SET @StatusMESSAGE = 'ERROR on:: ' + @ErrorStep
                                   + ' #:: ' + cast(ERROR_NUMBER() as varchar(20))
                                   + ' SEV:: ' + cast(ERROR_SEVERITY() as varchar(20))
                                   + ' LINE:: ' + cast(ERROR_LINE() as varchar(20))
                                   + ' MSG:: ' + ERROR_MESSAGE()
                                   + ' INTO:: ' + ERROR_PROCEDURE();
                      SET @ReturnCODE = 500;
                      SET @StatusCODE = 500;

            END CATCH
          END
        END

      EXEC @ReturnJSON = [dbo].[HvJSON_build] @apiVersion,@data,@StatusCODE,@StatusMESSAGE,@params;
      SELECT @ReturnJSON AS [ReturnJSON];
      RETURN @ReturnCODE;

GO

/************  PROCEDURE  addPassTrack    ****************/
CREATE OR ALTER PROCEDURE [dbo].[deleteChat]
    @InputJSON NVARCHAR(MAX),
    @ReturnJSON NVARCHAR(MAX) output -- if needed
    AS

      --declaration of variables to form JSON
      DECLARE @apiVersion NVARCHAR(20) = '1.0';
      DECLARE @data NVARCHAR(MAX);
      DECLARE @StatusMESSAGE NVARCHAR(500);
      DECLARE @StatusCODE INT;
      DECLARE @ErrorStep NVARCHAR(200)='';
      DECLARE @params NVARCHAR(MAX);

      --declaration of variables
      DECLARE @ReturnCODE int = 200 -- Comentar posible valores: 200 ok, 202 acepted, 400 bad request, 401 unauthorized, 500 error
      DECLARE @chatID BIGINT

      IF ISJSON(@InputJSON) = 0
        BEGIN
          SET @StatusMESSAGE='Incorrect JSON';
          SET @ReturnCODE = 400;
          SET @StatusCODE = 400;
        END
      ELSE
        BEGIN

          SET @chatID = JSON_VALUE(@InputJSON,'$.params.chatID');


          IF (@chatID IS NULL OR @chatID = '')
            BEGIN
              SET @StatusMESSAGE='Chat cant be null';
              SET @ReturnCODE = 400;
              SET @StatusCODE = 400;
            END
          ELSE IF (SELECT COUNT(*) FROM Chats WHERE chatID = @chatID AND isClosed = 0) = 0
            BEGIN
              SET @StatusMESSAGE='This chat dont exist';
              SET @ReturnCODE = 400;
              SET @StatusCODE = 400;
            END
          ELSE
            BEGIN

            -- execution
            BEGIN TRY
              BEGIN TRANSACTION

                  UPDATE Chats
                  SET isClosed = 1
                  WHERE chatID = @chatID
                  SET @StatusMESSAGE='Chat deleted';
                  SET @ReturnCODE = 200;
                  SET @StatusCODE = 200;


                  COMMIT TRANSACTION
                END TRY

                BEGIN CATCH
                      IF @@TRANCOUNT > 0 ROLLBACK

                      -- TODO :: un mensaje de error , a log, tal y como esta en el example for sql code
                      SET @StatusMESSAGE = 'ERROR on:: ' + @ErrorStep
                                   + ' #:: ' + cast(ERROR_NUMBER() as varchar(20))
                                   + ' SEV:: ' + cast(ERROR_SEVERITY() as varchar(20))
                                   + ' LINE:: ' + cast(ERROR_LINE() as varchar(20))
                                   + ' MSG:: ' + ERROR_MESSAGE()
                                   + ' INTO:: ' + ERROR_PROCEDURE();
                      SET @ReturnCODE = 500;
                      SET @StatusCODE = 500;

            END CATCH
          END
        END

      EXEC @ReturnJSON = [dbo].[HvJSON_build] @apiVersion,@data,@StatusCODE,@StatusMESSAGE,@params;
      SELECT @ReturnJSON AS [ReturnJSON];
      RETURN @ReturnCODE;

GO


/************  PROCEDURE  addPassTrack    ****************/
CREATE OR ALTER PROCEDURE [dbo].[saveMessage]
    @InputJSON NVARCHAR(MAX),
    @ReturnJSON NVARCHAR(MAX) output -- if needed
    AS

      --declaration of variables to form JSON
      DECLARE @apiVersion NVARCHAR(20) = '1.0';
      DECLARE @data NVARCHAR(MAX);
      DECLARE @StatusMESSAGE NVARCHAR(500);
      DECLARE @StatusCODE INT;
      DECLARE @ErrorStep NVARCHAR(200)='';
      DECLARE @params NVARCHAR(MAX);

      --declaration of variables
      DECLARE @ReturnCODE int = 200 -- Comentar posible valores: 200 ok, 202 acepted, 400 bad request, 401 unauthorized, 500 error
      DECLARE @chatID BIGINT
      DECLARE @userID BIGINT
      DECLARE @chatUserID BIGINT
      DECLARE @message NVARCHAR(MAX)
      DECLARE @sendTimestamp NVARCHAR(50)

      IF ISJSON(@InputJSON) = 0
        BEGIN
          SET @StatusMESSAGE='Incorrect JSON';
          SET @ReturnCODE = 400;
          SET @StatusCODE = 400;
        END
      ELSE
        BEGIN

          SET @chatID = JSON_VALUE(@InputJSON,'$.params.chatID');
          SET @userID = JSON_VALUE(@InputJSON,'$.params.userID');
          SET @chatUserID = JSON_VALUE(@InputJSON,'$.params.chatUserID');
          SET @message = JSON_VALUE(@InputJSON,'$.params.message');
          SET @sendTimestamp = JSON_VALUE(@InputJSON,'$.params.sendTimestamp');

          IF (@chatID IS NULL OR @chatID = '' OR @userID IS NULL OR @userID = '' OR @message IS NULL OR @message = '')
            BEGIN
              SET @StatusMESSAGE='Chat cant be null';
              SET @ReturnCODE = 400;
              SET @StatusCODE = 400;
            END
          ELSE IF (SELECT COUNT(*) FROM Users WHERE userID = @userID) = 0
            BEGIN
              SET @StatusMESSAGE='This user dont exist';
              SET @ReturnCODE = 400;
              SET @StatusCODE = 400;
            END
          ELSE IF (SELECT COUNT(*) FROM Chats WHERE chatID = @chatID AND isClosed = 0) = 0
            BEGIN
              SET @StatusMESSAGE='This chat dont exist';
              SET @ReturnCODE = 400;
              SET @StatusCODE = 400;
            END
          ELSE
            BEGIN

            -- execution
            BEGIN TRY
              BEGIN TRANSACTION



                  INSERT INTO Messages
                    (chatID, userID, message, sendTimestamp)
                  VALUES
                    (@chatID, @userID, @message, @sendTimestamp)
                  SET @data = (select @chatUserID as [chatUserID] FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
                  SET @StatusMESSAGE='Message saved';
                  SET @ReturnCODE = 200;
                  SET @StatusCODE = 200;


                  COMMIT TRANSACTION
                END TRY

                BEGIN CATCH
                      IF @@TRANCOUNT > 0 ROLLBACK

                      -- TODO :: un mensaje de error , a log, tal y como esta en el example for sql code
                      SET @StatusMESSAGE = 'ERROR on:: ' + @ErrorStep
                                   + ' #:: ' + cast(ERROR_NUMBER() as varchar(20))
                                   + ' SEV:: ' + cast(ERROR_SEVERITY() as varchar(20))
                                   + ' LINE:: ' + cast(ERROR_LINE() as varchar(20))
                                   + ' MSG:: ' + ERROR_MESSAGE()
                                   + ' INTO:: ' + ERROR_PROCEDURE();
                      SET @ReturnCODE = 500;
                      SET @StatusCODE = 500;

            END CATCH
          END
        END

      EXEC @ReturnJSON = [dbo].[HvJSON_build] @apiVersion,@data,@StatusCODE,@StatusMESSAGE,@params;
      SELECT @ReturnJSON AS [ReturnJSON];
      RETURN @ReturnCODE;

GO

/************  PROCEDURE  addPassTrack    ****************/
CREATE OR ALTER PROCEDURE [dbo].[createChat]
    @InputJSON NVARCHAR(MAX),
    @ReturnJSON NVARCHAR(MAX) output -- if needed
    AS

      --declaration of variables to form JSON
      DECLARE @apiVersion NVARCHAR(20) = '1.0';
      DECLARE @data NVARCHAR(MAX);
      DECLARE @StatusMESSAGE NVARCHAR(500);
      DECLARE @StatusCODE INT;
      DECLARE @ErrorStep NVARCHAR(200)='';
      DECLARE @params NVARCHAR(MAX);

      --declaration of variables
      DECLARE @ReturnCODE int = 200 -- Comentar posible valores: 200 ok, 202 acepted, 400 bad request, 401 unauthorized, 500 error
      DECLARE @userID BIGINT
      DECLARE @expertID BIGINT
      DECLARE @username NVARCHAR(50)
      DECLARE @expertName NVARCHAR(50)

      IF ISJSON(@InputJSON) = 0
        BEGIN
          SET @StatusMESSAGE='Incorrect JSON';
          SET @ReturnCODE = 400;
          SET @StatusCODE = 400;
        END
      ELSE
        BEGIN

          SET @userID = JSON_VALUE(@InputJSON,'$.params.userID');
          SET @expertID = JSON_VALUE(@InputJSON,'$.params.expertID');
          SET @username = JSON_VALUE(@InputJSON,'$.params.username');
          SET @expertName = JSON_VALUE(@InputJSON,'$.params.expertName');

          IF (@expertID IS NULL OR @expertID = '' OR @userID IS NULL OR @userID = '' OR @username IS NULL OR @username = ''
              OR @expertName IS NULL OR @expertName = '')
            BEGIN
              SET @StatusMESSAGE='Atributes cant be null';
              SET @ReturnCODE = 400;
              SET @StatusCODE = 400;
            END
          ELSE IF (SELECT COUNT(*) FROM Users WHERE userID = @userID) = 0
            BEGIN
              SET @StatusMESSAGE='This user dont exist';
              SET @ReturnCODE = 400;
              SET @StatusCODE = 400;
            END
          ELSE IF (SELECT COUNT(*) FROM Users WHERE userID = @expertID) = 0
            BEGIN
              SET @StatusMESSAGE='This expert dont exist';
              SET @ReturnCODE = 400;
              SET @StatusCODE = 400;
            END
          ELSE
            BEGIN

            -- execution
            BEGIN TRY
              BEGIN TRANSACTION


               IF (SELECT COUNT(*) FROM Chats WHERE [user] = @userID AND userExpert = @expertID AND isClosed = 0) = 1
                BEGIN

                  SET @StatusMESSAGE='Chats exist';

                END
              ELSE
                BEGIN

                  INSERT INTO Chats
                    ([user], userExpert, username, usernameExpert)
                  VALUES
                    (@userID, @expertID, @username, @expertName)
                  SET @StatusMESSAGE='Chat created';

                END

                  SET @data = (select * FROM Chats WHERE [user] = @userID AND userExpert = @expertID AND isClosed = 0 FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
                  SET @ReturnCODE = 200;
                  SET @StatusCODE = 200;


                  COMMIT TRANSACTION
                END TRY

                BEGIN CATCH
                      IF @@TRANCOUNT > 0 ROLLBACK

                      -- TODO :: un mensaje de error , a log, tal y como esta en el example for sql code
                      SET @StatusMESSAGE = 'ERROR on:: ' + @ErrorStep
                                   + ' #:: ' + cast(ERROR_NUMBER() as varchar(20))
                                   + ' SEV:: ' + cast(ERROR_SEVERITY() as varchar(20))
                                   + ' LINE:: ' + cast(ERROR_LINE() as varchar(20))
                                   + ' MSG:: ' + ERROR_MESSAGE()
                                   + ' INTO:: ' + ERROR_PROCEDURE();
                      SET @ReturnCODE = 500;
                      SET @StatusCODE = 500;

            END CATCH
          END
        END

      EXEC @ReturnJSON = [dbo].[HvJSON_build] @apiVersion,@data,@StatusCODE,@StatusMESSAGE,@params;
      SELECT @ReturnJSON AS [ReturnJSON];
      RETURN @ReturnCODE;

GO

/************  PROCEDURE  addPassTrack    ****************/
CREATE OR ALTER PROCEDURE [dbo].[getExperts]
    @InputJSON NVARCHAR(MAX),
    @ReturnJSON NVARCHAR(MAX) output -- if needed
    AS

      --declaration of variables to form JSON
      DECLARE @apiVersion NVARCHAR(20) = '1.0';
      DECLARE @data NVARCHAR(MAX);
      DECLARE @StatusMESSAGE NVARCHAR(500);
      DECLARE @StatusCODE INT;
      DECLARE @ErrorStep NVARCHAR(200)='';
      DECLARE @params NVARCHAR(MAX);

      --declaration of variables
      DECLARE @ReturnCODE int = 200 -- Comentar posible valores: 200 ok, 202 acepted, 400 bad request, 401 unauthorized, 500 error
      DECLARE @byUserID BIGINT

      IF ISJSON(@InputJSON) = 0
        BEGIN
          SET @StatusMESSAGE='Incorrect JSON';
          SET @ReturnCODE = 400;
          SET @StatusCODE = 400;
        END
      ELSE
        BEGIN

          SET @byUserID = JSON_VALUE(@InputJSON,'$.params.userID');


          IF (@byUserID IS NULL OR @byUserID = '')
            BEGIN
              SET @StatusMESSAGE='user cant be null';
              SET @ReturnCODE = 400;
              SET @StatusCODE = 400;
            END
          ELSE IF (SELECT COUNT(*) FROM Users WHERE userID = @byUserID) = 0
            BEGIN
              SET @StatusMESSAGE='This user dont exist';
              SET @ReturnCODE = 400;
              SET @StatusCODE = 400;
            END
          ELSE
            BEGIN

            -- execution
            BEGIN TRY
              BEGIN TRANSACTION


                  DECLARE @userID BIGINT
                  DECLARE @username NVARCHAR(50)
                  DECLARE @tempTable TABLE (userID BIGINT, username NVARCHAR(50), averageRating INT)
                  DECLARE cursor_usuarios CURSOR FOR
                  SELECT userID, username
                  FROM Users
                  WHERE type = 1

                  OPEN cursor_usuarios

                  FETCH NEXT FROM cursor_usuarios
                  INTO @userID, @username

                  WHILE @@FETCH_STATUS = 0
                  BEGIN

                    DECLARE @numRating INT;
                    DECLARE @totalRating INT;
                    DECLARE @average INT

                    SELECT @numRating = count(*) FROM Ratings WHERE userID = @userID
                    SELECT @totalRating = sum(value) FROM Ratings WHERE userID = @userID
                    SET @average = @totalRating / @numRating;
                    IF (@average IS NULL)
                    BEGIN
                      SET @average = 0;
                    END
                    INSERT INTO @tempTable (userID, username, averageRating)
                    VALUES (@userID, @username, @average)

                    FETCH NEXT FROM cursor_usuarios
                    INTO @userID, @username
                  END
                  CLOSE cursor_usuarios;
                  DEALLOCATE cursor_usuarios;


                  SET @data = (select (SELECT * FROM @tempTable FOR JSON PATH) AS [experts] for json path,WITHOUT_ARRAY_WRAPPER );
                  SET @StatusMESSAGE='OK';
                  SET @ReturnCODE = 200;
                  SET @StatusCODE = 200;


                  COMMIT TRANSACTION
                END TRY

                BEGIN CATCH
                      IF @@TRANCOUNT > 0 ROLLBACK

                      -- TODO :: un mensaje de error , a log, tal y como esta en el example for sql code
                      SET @StatusMESSAGE = 'ERROR on:: ' + @ErrorStep
                                   + ' #:: ' + cast(ERROR_NUMBER() as varchar(20))
                                   + ' SEV:: ' + cast(ERROR_SEVERITY() as varchar(20))
                                   + ' LINE:: ' + cast(ERROR_LINE() as varchar(20))
                                   + ' MSG:: ' + ERROR_MESSAGE()
                                   + ' INTO:: ' + ERROR_PROCEDURE();
                      SET @ReturnCODE = 500;
                      SET @StatusCODE = 500;

            END CATCH
          END
        END

      EXEC @ReturnJSON = [dbo].[HvJSON_build] @apiVersion,@data,@StatusCODE,@StatusMESSAGE,@params;
      SELECT @ReturnJSON AS [ReturnJSON];
      RETURN @ReturnCODE;

GO

/************  PROCEDURE  addPassTrack    ****************/
CREATE OR ALTER PROCEDURE [dbo].[createRating]
    @InputJSON NVARCHAR(MAX),
    @ReturnJSON NVARCHAR(MAX) output -- if needed
    AS

      --declaration of variables to form JSON
      DECLARE @apiVersion NVARCHAR(20) = '1.0';
      DECLARE @data NVARCHAR(MAX);
      DECLARE @StatusMESSAGE NVARCHAR(500);
      DECLARE @StatusCODE INT;
      DECLARE @ErrorStep NVARCHAR(200)='';
      DECLARE @params NVARCHAR(MAX);

      --declaration of variables
      DECLARE @ReturnCODE int = 200 -- Comentar posible valores: 200 ok, 202 acepted, 400 bad request, 401 unauthorized, 500 error
      DECLARE @userID BIGINT
      DECLARE @value INT

      IF ISJSON(@InputJSON) = 0
        BEGIN
          SET @StatusMESSAGE='Incorrect JSON';
          SET @ReturnCODE = 400;
          SET @StatusCODE = 400;
        END
      ELSE
        BEGIN

          SET @userID = JSON_VALUE(@InputJSON,'$.params.userID');
          SET @value = JSON_VALUE(@InputJSON,'$.params.value');


          IF (@userID IS NULL OR @userID = '' OR @value IS NULL OR @value = '')
            BEGIN
              SET @StatusMESSAGE='Insuficient parameters';
              SET @ReturnCODE = 400;
              SET @StatusCODE = 400;
            END
          ELSE IF (SELECT COUNT(*) FROM Users WHERE userID = @userID) = 0
            BEGIN
              SET @StatusMESSAGE='This user dont exist';
              SET @ReturnCODE = 400;
              SET @StatusCODE = 400;
            END
          ELSE
            BEGIN

            -- execution
            BEGIN TRY
              BEGIN TRANSACTION


                  INSERT INTO Ratings
                  (userID, value)
                  VALUES
                  (@userID,@value)
                  SET @StatusMESSAGE='Rating created';
                  SET @ReturnCODE = 200;
                  SET @StatusCODE = 200;


                  COMMIT TRANSACTION
                END TRY

                BEGIN CATCH
                      IF @@TRANCOUNT > 0 ROLLBACK

                      -- TODO :: un mensaje de error , a log, tal y como esta en el example for sql code
                      SET @StatusMESSAGE = 'ERROR on:: ' + @ErrorStep
                                   + ' #:: ' + cast(ERROR_NUMBER() as varchar(20))
                                   + ' SEV:: ' + cast(ERROR_SEVERITY() as varchar(20))
                                   + ' LINE:: ' + cast(ERROR_LINE() as varchar(20))
                                   + ' MSG:: ' + ERROR_MESSAGE()
                                   + ' INTO:: ' + ERROR_PROCEDURE();
                      SET @ReturnCODE = 500;
                      SET @StatusCODE = 500;

            END CATCH
          END
        END

      EXEC @ReturnJSON = [dbo].[HvJSON_build] @apiVersion,@data,@StatusCODE,@StatusMESSAGE,@params;
      SELECT @ReturnJSON AS [ReturnJSON];
      RETURN @ReturnCODE;

GO

/************  PROCEDURE  addPassTrack    ****************/
CREATE OR ALTER PROCEDURE [dbo].[averageRating]
    @InputJSON NVARCHAR(MAX),
    @ReturnJSON NVARCHAR(MAX) output -- if needed
    AS

      --declaration of variables to form JSON
      DECLARE @apiVersion NVARCHAR(20) = '1.0';
      DECLARE @data NVARCHAR(MAX);
      DECLARE @StatusMESSAGE NVARCHAR(500);
      DECLARE @StatusCODE INT;
      DECLARE @ErrorStep NVARCHAR(200)='';
      DECLARE @params NVARCHAR(MAX);

      --declaration of variables
      DECLARE @ReturnCODE int = 200 -- Comentar posible valores: 200 ok, 202 acepted, 400 bad request, 401 unauthorized, 500 error
      DECLARE @userID BIGINT

      IF ISJSON(@InputJSON) = 0
        BEGIN
          SET @StatusMESSAGE='Incorrect JSON';
          SET @ReturnCODE = 400;
          SET @StatusCODE = 400;
        END
      ELSE
        BEGIN

          SET @userID = JSON_VALUE(@InputJSON,'$.params.userID');


          IF (@userID IS NULL OR @userID = '')
            BEGIN
              SET @StatusMESSAGE='User cant be null';
              SET @ReturnCODE = 400;
              SET @StatusCODE = 400;
            END
          ELSE IF (SELECT COUNT(*) FROM Users WHERE userID = @userID) = 0
            BEGIN
              SET @StatusMESSAGE='This user dont exist';
              SET @ReturnCODE = 400;
              SET @StatusCODE = 400;
            END
          ELSE
            BEGIN

            -- execution
            BEGIN TRY
              BEGIN TRANSACTION


              DECLARE @numRating INT;
              DECLARE @totalRating INT;
              DECLARE @average INT

              SELECT @numRating = count(*) FROM Ratings WHERE userID = @userID
              SELECT @totalRating = sum(value) FROM Ratings WHERE userID = @userID
              SET @average = @totalRating / @numRating;

              SET @data = (SELECT @average as [averageRating], @userID as [userID] FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
              IF (@average != '' AND @average IS NOT NULL)
                BEGIN
                  SET @StatusMESSAGE='Rating average';
                END
              ELSE
                BEGIN
                  SET @StatusMESSAGE='No Ratings';
                END

              SET @ReturnCODE = 200;
              SET @StatusCODE = 200;


                  COMMIT TRANSACTION
                END TRY

                BEGIN CATCH
                      IF @@TRANCOUNT > 0 ROLLBACK

                      -- TODO :: un mensaje de error , a log, tal y como esta en el example for sql code
                      SET @StatusMESSAGE = 'ERROR on:: ' + @ErrorStep
                                   + ' #:: ' + cast(ERROR_NUMBER() as varchar(20))
                                   + ' SEV:: ' + cast(ERROR_SEVERITY() as varchar(20))
                                   + ' LINE:: ' + cast(ERROR_LINE() as varchar(20))
                                   + ' MSG:: ' + ERROR_MESSAGE()
                                   + ' INTO:: ' + ERROR_PROCEDURE();
                      SET @ReturnCODE = 500;
                      SET @StatusCODE = 500;

            END CATCH
          END
        END

      EXEC @ReturnJSON = [dbo].[HvJSON_build] @apiVersion,@data,@StatusCODE,@StatusMESSAGE,@params;
      SELECT @ReturnJSON AS [ReturnJSON];
      RETURN @ReturnCODE;

GO


/************  PROCEDURE  addPassTrack    ****************/
CREATE OR ALTER PROCEDURE [dbo].[createNote]
    @InputJSON NVARCHAR(MAX),
    @ReturnJSON NVARCHAR(MAX) output -- if needed
    AS

      --declaration of variables to form JSON
      DECLARE @apiVersion NVARCHAR(20) = '1.0';
      DECLARE @data NVARCHAR(MAX);
      DECLARE @StatusMESSAGE NVARCHAR(500);
      DECLARE @StatusCODE INT;
      DECLARE @ErrorStep NVARCHAR(200)='';
      DECLARE @params NVARCHAR(MAX);

      --declaration of variables
      DECLARE @ReturnCODE int = 200 -- Comentar posible valores: 200 ok, 202 acepted, 400 bad request, 401 unauthorized, 500 error
      DECLARE @userID BIGINT
      DECLARE @byUserID BIGINT
      DECLARE @noteText NVARCHAR(MAX)

      IF ISJSON(@InputJSON) = 0
        BEGIN
          SET @StatusMESSAGE='Incorrect JSON';
          SET @ReturnCODE = 400;
          SET @StatusCODE = 400;
        END
      ELSE
        BEGIN

          SET @userID = JSON_VALUE(@InputJSON,'$.params.userID');
          SET @byUserID = JSON_VALUE(@InputJSON,'$.params.byUserID');
          SET @noteText = JSON_VALUE(@InputJSON,'$.params.noteText');


          IF (@userID IS NULL OR @userID = '' OR @byUserID IS NULL OR @byUserID = ''
          OR @noteText IS NULL OR @noteText = '')
            BEGIN
              SET @StatusMESSAGE='Insuficient parameters';
              SET @ReturnCODE = 400;
              SET @StatusCODE = 400;
            END
          ELSE IF (SELECT COUNT(*) FROM Users WHERE userID = @userID) = 0
            BEGIN
              SET @StatusMESSAGE='This user dont exist';
              SET @ReturnCODE = 400;
              SET @StatusCODE = 400;
            END
          ELSE IF (SELECT COUNT(*) FROM Users WHERE userID = @byUserID) = 0
            BEGIN
              SET @StatusMESSAGE='This user dont exist';
              SET @ReturnCODE = 400;
              SET @StatusCODE = 400;
            END
          ELSE
            BEGIN

            -- execution
            BEGIN TRY
              BEGIN TRANSACTION


                  INSERT INTO Notes
                  (userID, byUserID, noteText)
                  VALUES
                  (@userID,@byUserID,@noteText)
                  SET @StatusMESSAGE='Note created';
                  SET @ReturnCODE = 200;
                  SET @StatusCODE = 200;


                  COMMIT TRANSACTION
                END TRY

                BEGIN CATCH
                      IF @@TRANCOUNT > 0 ROLLBACK

                      -- TODO :: un mensaje de error , a log, tal y como esta en el example for sql code
                      SET @StatusMESSAGE = 'ERROR on:: ' + @ErrorStep
                                   + ' #:: ' + cast(ERROR_NUMBER() as varchar(20))
                                   + ' SEV:: ' + cast(ERROR_SEVERITY() as varchar(20))
                                   + ' LINE:: ' + cast(ERROR_LINE() as varchar(20))
                                   + ' MSG:: ' + ERROR_MESSAGE()
                                   + ' INTO:: ' + ERROR_PROCEDURE();
                      SET @ReturnCODE = 500;
                      SET @StatusCODE = 500;

            END CATCH
          END
        END

      EXEC @ReturnJSON = [dbo].[HvJSON_build] @apiVersion,@data,@StatusCODE,@StatusMESSAGE,@params;
      SELECT @ReturnJSON AS [ReturnJSON];
      RETURN @ReturnCODE;

GO



/************  PROCEDURE  addPassTrack    ****************/
CREATE OR ALTER PROCEDURE [dbo].[getNotes]
    @InputJSON NVARCHAR(MAX),
    @ReturnJSON NVARCHAR(MAX) output -- if needed
    AS

      --declaration of variables to form JSON
      DECLARE @apiVersion NVARCHAR(20) = '1.0';
      DECLARE @data NVARCHAR(MAX);
      DECLARE @StatusMESSAGE NVARCHAR(500);
      DECLARE @StatusCODE INT;
      DECLARE @ErrorStep NVARCHAR(200)='';
      DECLARE @params NVARCHAR(MAX);

      --declaration of variables
      DECLARE @ReturnCODE int = 200 -- Comentar posible valores: 200 ok, 202 acepted, 400 bad request, 401 unauthorized, 500 error
      DECLARE @userID BIGINT

      IF ISJSON(@InputJSON) = 0
        BEGIN
          SET @StatusMESSAGE='Incorrect JSON';
          SET @ReturnCODE = 400;
          SET @StatusCODE = 400;
        END
      ELSE
        BEGIN

          SET @userID = JSON_VALUE(@InputJSON,'$.params.userID');


          IF (@userID IS NULL OR @userID = '')
            BEGIN
              SET @StatusMESSAGE='User cant be null';
              SET @ReturnCODE = 400;
              SET @StatusCODE = 400;
            END
          ELSE IF (SELECT COUNT(*) FROM Users WHERE userID = @userID) = 0
            BEGIN
              SET @StatusMESSAGE='This user dont exist';
              SET @ReturnCODE = 400;
              SET @StatusCODE = 400;
            END
          ELSE
            BEGIN

            -- execution
            BEGIN TRY
              BEGIN TRANSACTION


                  SET @data = (select (SELECT * FROM Notes WHERE userID = @userID FOR JSON PATH) AS [notesList] for json path,WITHOUT_ARRAY_WRAPPER );
                  SET @StatusMESSAGE='Note created';
                  SET @ReturnCODE = 200;
                  SET @StatusCODE = 200;


                  COMMIT TRANSACTION
                END TRY

                BEGIN CATCH
                      IF @@TRANCOUNT > 0 ROLLBACK

                      -- TODO :: un mensaje de error , a log, tal y como esta en el example for sql code
                      SET @StatusMESSAGE = 'ERROR on:: ' + @ErrorStep
                                   + ' #:: ' + cast(ERROR_NUMBER() as varchar(20))
                                   + ' SEV:: ' + cast(ERROR_SEVERITY() as varchar(20))
                                   + ' LINE:: ' + cast(ERROR_LINE() as varchar(20))
                                   + ' MSG:: ' + ERROR_MESSAGE()
                                   + ' INTO:: ' + ERROR_PROCEDURE();
                      SET @ReturnCODE = 500;
                      SET @StatusCODE = 500;

            END CATCH
          END
        END

      EXEC @ReturnJSON = [dbo].[HvJSON_build] @apiVersion,@data,@StatusCODE,@StatusMESSAGE,@params;
      SELECT @ReturnJSON AS [ReturnJSON];
      RETURN @ReturnCODE;

GO

/************  PROCEDURE  addPassTrack    ****************/
CREATE OR ALTER PROCEDURE [dbo].[recoveryPass]
    @InputJSON NVARCHAR(MAX),
    @ReturnJSON NVARCHAR(MAX) output -- if needed
    AS

      --declaration of variables to form JSON
      DECLARE @apiVersion NVARCHAR(20) = '1.0';
      DECLARE @data NVARCHAR(MAX);
      DECLARE @StatusMESSAGE NVARCHAR(500);
      DECLARE @StatusCODE INT;
      DECLARE @ErrorStep NVARCHAR(200)='';
      DECLARE @params NVARCHAR(MAX);

      --declaration of variables
      DECLARE @ReturnCODE int = 200 -- Comentar posible valores: 200 ok, 202 acepted, 400 bad request, 401 unauthorized, 500 error
      DECLARE @username nvarchar(100)

      IF ISJSON(@InputJSON) = 0
        BEGIN
          SET @StatusMESSAGE='Incorrect JSON';
          SET @ReturnCODE = 400;
          SET @StatusCODE = 400;
        END
      ELSE
        BEGIN

          SET @username = JSON_VALUE(@InputJSON,'$.params.username');


          IF (@username IS NULL OR @username = '')
            BEGIN
              SET @StatusMESSAGE='username cant be null';
              SET @ReturnCODE = 400;
              SET @StatusCODE = 400;
            END
          ELSE IF (SELECT COUNT(*) FROM Users WHERE username = @username) = 0
            BEGIN
              SET @StatusMESSAGE='This username dont exist';
              SET @ReturnCODE = 400;
              SET @StatusCODE = 400;
            END
          ELSE
            BEGIN

            -- execution
            BEGIN TRY
              BEGIN TRANSACTION

                  DECLARE @newPass nvarchar(50);
                  DECLARE @email nvarchar(50);
                  select @newPass = cast((Abs(Checksum(NewId()))%10) as varchar(1)) +
                  char(ascii('a')+(Abs(Checksum(NewId()))%25)) +
                  char(ascii('A')+(Abs(Checksum(NewId()))%25)) +
                  left(newid(),5)
                  select @email = email FROM Users where username = @username

                  UPDATE Users
                  SET pass = @newPass
                  WHERE username = @username;
                  SET @data = (select @email as email, @newPass as [newPass]  for json path,WITHOUT_ARRAY_WRAPPER );
                  SET @StatusMESSAGE='Email send';
                  SET @ReturnCODE = 200;
                  SET @StatusCODE = 200;


                  COMMIT TRANSACTION
                END TRY

                BEGIN CATCH
                      IF @@TRANCOUNT > 0 ROLLBACK

                      -- TODO :: un mensaje de error , a log, tal y como esta en el example for sql code
                      SET @StatusMESSAGE = 'ERROR on:: ' + @ErrorStep
                                   + ' #:: ' + cast(ERROR_NUMBER() as varchar(20))
                                   + ' SEV:: ' + cast(ERROR_SEVERITY() as varchar(20))
                                   + ' LINE:: ' + cast(ERROR_LINE() as varchar(20))
                                   + ' MSG:: ' + ERROR_MESSAGE()
                                   + ' INTO:: ' + ERROR_PROCEDURE();
                      SET @ReturnCODE = 500;
                      SET @StatusCODE = 500;

            END CATCH
          END
        END

      EXEC @ReturnJSON = [dbo].[HvJSON_build] @apiVersion,@data,@StatusCODE,@StatusMESSAGE,@params;
      SELECT @ReturnJSON AS [ReturnJSON];
      RETURN @ReturnCODE;

GO
