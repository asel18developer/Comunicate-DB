/************************************************************/
/*****                                                  *****/
/*****         SQL_SCRIPT :: mssql-functions-script     *****/
/*****                v00.100 - 2017.04.12              *****/
/*****                                                  *****/
/************************************************************/


/*
 * HvJSON_build --> This function creates a json with the chosen format.
 */
CREATE OR ALTER FUNCTION [dbo].[HvJSON_build] (
    @apiVersion NVARCHAR(20),
    @data NVARCHAR(MAX),
    @StatusCODE INT,
    @StatusMESSAGE NVARCHAR(500),
    @params NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS BEGIN

    /* @ReturnJSON the output variable */
    DECLARE @ReturnJSON NVARCHAR(MAX)

    /*
     * Cleaning input parameters
     */
    IF (@apiVersion IS NULL OR @StatusCODE IS NULL) -- Mandatory parameters
      BEGIN

        SET @StatusCODE = 500;
        SET @StatusMESSAGE = 'Error: Insufficient mandatory parameters';

      END
    ELSE IF (ISJSON(@data) = 0 AND @data IS NOT NULL)
      BEGIN

        SET @StatusCODE = 500;
        SET @StatusMESSAGE = 'Error: JSON data incorrect format';

      END
    ELSE IF (ISJSON(@params) = 0 AND @params IS NOT NULL)
      BEGIN

        SET @StatusCODE = 500;
        SET @StatusMESSAGE = 'Error: JSON params incorrect format';

      END

    /*
     * Creation of JSON with input parameter parameters
     */
    SET @ReturnJSON = (select @apiVersion AS [apiVersion],
					            JSON_QUERY(@params) as [params],
                      JSON_QUERY(@data) as [data],
                      JSON_QUERY(((
                      select @StatusMESSAGE as [message], @StatusCODE as [code] for json path, WITHOUT_ARRAY_WRAPPER)))
                      as [status] for json path, WITHOUT_ARRAY_WRAPPER);

      RETURN @ReturnJSON

END
/************************************************************/
/*****         END  Sql_SCRIPT :: HvP__functions               *****/
/************************************************************/
