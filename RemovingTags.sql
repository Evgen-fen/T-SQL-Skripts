USE [DataBase];
GO


CREATE OR ALTER FUNCTION [dbo].[RemovingTags] (@str NVARCHAR(MAX))  -- Delete html tags from string
RETURNS VARCHAR(MAX) AS
BEGIN
    DECLARE @Start INT
    DECLARE @End INT
    DECLARE @Length INT
    SET @Start = CHARINDEX('<',@str)
    SET @End = CHARINDEX('>',@str,CHARINDEX('<',@str))
    SET @Length = (@End - @Start) + 1
    WHILE @Start > 0 AND @End > 0 AND @Length > 0
    BEGIN
        SET @str = STUFF(@str,@Start,@Length,'')
        SET @Start = CHARINDEX('<',@str)
        SET @End = CHARINDEX('>',@str,CHARINDEX('<',@str))
        SET @Length = (@End - @Start) + 1
    END
    RETURN LTRIM(RTRIM(@str))
END;




