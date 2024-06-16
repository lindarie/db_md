CREATE TABLE KreditaMaksajumi (
    Month INT,
    pamatsummasAtlikums DECIMAL(18,2),
    procentuMaksajums DECIMAL(18,2),
    pamatsummasMaksajums DECIMAL(18,2),
    kopejaisMaksajums DECIMAL(18,2),
	kreditaVeids NVARCHAR(100)
);
GO

CREATE OR ALTER PROCEDURE kreditaKalkulators @cena FLOAT, @iemaksa FLOAT, @gadi INT, @likme FLOAT, @veids INT
AS
BEGIN
    DECLARE @menesaLikme FLOAT;
    DECLARE @P FLOAT;
    DECLARE @N INT;
    DECLARE @Pmt FLOAT;
    DECLARE @month INT = 1;
    DECLARE @pamatsummasAtlikums FLOAT;
    DECLARE @procentuMaksajums FLOAT;
    DECLARE @pamatsummasMaksajums FLOAT;
    DECLARE @kopejaisMaksajums FLOAT;
	DECLARE @kreditaVeids NVARCHAR(100);

	TRUNCATE TABLE KreditaMaksajumi;

	IF @iemaksa < 0 OR @likme < 0 OR @cena < 0 OR @veids < 0 OR @gadi < 0
    BEGIN
        RAISERROR('Vērtības nevar būt negatīvas', 16, 1);
        RETURN;
    END

	-- aprēķina parādu, mēnešu skaitu un likmi
    SET @P = @cena * (1 - @iemaksa / 100);
    SET @N = @gadi * 12;
    SET @menesaLikme = @likme / (12 * 100);
	
    -- mēneša maksājums katram kredīta veidam
    IF @veids = 1
    BEGIN
        SET @Pmt = @P * @menesaLikme / (1 - POWER(1 + @menesaLikme, -@N));
		SET @kreditaVeids = 'vienmērīgs';
    END
    ELSE IF @veids = 2
    BEGIN
        SET @Pmt = @P / @N;
		SET @kreditaVeids = 'dilstošs';
    END

    WHILE @month <= @N
    BEGIN
        SET @procentuMaksajums = @P * @menesaLikme;
        
		IF @veids = 1
		BEGIN
			SET @kopejaisMaksajums = @Pmt;
		END
		ELSE IF @veids = 2
		BEGIN
			SET @kopejaisMaksajums = @Pmt + @procentuMaksajums;
		END

		SET @pamatsummasMaksajums = @kopejaisMaksajums - @procentuMaksajums;
        SET @pamatsummasAtlikums = @P;

        INSERT INTO KreditaMaksajumi VALUES (@month, @pamatsummasAtlikums, @procentuMaksajums, @pamatsummasMaksajums, @kopejaisMaksajums, @kreditaVeids);
        
		SET @P = @P - @pamatsummasMaksajums;
        SET @month = @month + 1;
    END

	SELECT TOP 1 kreditaVeids as 'Hipotekārā kredīta veids'
	FROM KreditaMaksajumi;

	SELECT Month as 'Mēnesis', 
		   pamatsummasAtlikums as 'Kredīta pamatsummas atlikums', 
		   procentuMaksajums as 'Kredīta procentu maksājums',
		   pamatsummasMaksajums as 'Kredīta pamatsummas maksājums', 
		   kopejaisMaksajums as 'Kopējais mēneša maksājums'
	FROM KreditaMaksajumi;
END;


EXEC kreditaKalkulators @cena = 100000, @iemaksa = 15, @gadi = 10, @likme = 4.748, @veids = 1;
EXEC kreditaKalkulators @cena = 100000, @iemaksa = 15, @gadi = 10, @likme = 4.748, @veids = 2;

DROP TABLE KreditaMaksajumi;
