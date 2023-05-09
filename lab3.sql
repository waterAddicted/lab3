USE Inchiriere_Masini
go

CREATE OR ALTER FUNCTION ValideazaClient(@cnp varchar(50)) RETURNS INT AS
BEGIN
	DECLARE @ok INT
	SET @ok = 1
	IF(len(@cnp)!=13)
		SET @ok=0

	RETURN @ok
END
GO

CREATE OR ALTER FUNCTION ValideazaMasina(@nume varchar(50),@greutate int) RETURNS INT AS
BEGIN
	DECLARE @ok INT
	SET @ok = 1
	IF(len(@nume)=0 or @greutate <= 0)
		SET @ok=0

	RETURN @ok
END
GO

--ori toate ori niciuna
CREATE OR ALTER PROCEDURE AdaugaMasinaClientImpreuna (@cnp varchar(50),@nume varchar(50),@greutate int) AS
BEGIN
	BEGIN TRAN
		BEGIN TRY
			IF(dbo.ValideazaClient(@cnp)=0 OR dbo.ValideazaMasina(@nume,@greutate)=0)
			BEGIN
				RAISERROR('DATE INVALIDE!',14,1)
			END

			DECLARE @id_masina int
			SELECT @id_masina=MAX(id_masina) FROM Masina
			SET @id_masina=@id_masina+1

			INSERT INTO Client(cnp) VALUES (@cnp)
			INSERT INTO Masina(nume) VALUES (@nume)
			INSERT INTO Contract(id_masina,cnp) VALUES (@id_masina,@cnp)
		
			COMMIT TRAN
			SELECT 'COMMIT EFECTUAT'
		END TRY
		BEGIN CATCH
			ROLLBACK TRAN
			SELECT 'ROLLBACK EFECTUAT'
		END CATCH
END
			
GO

--insert pe rand, chiar daca una nu e ok
CREATE OR ALTER PROCEDURE AdaugaMasinaClientSeparat(@cnp varchar(50),@nume varchar(50),@greutate int) AS
BEGIN
	DECLARE @id_masina int
			SELECT @id_masina=MAX(id_masina) FROM Masina
			SET @id_masina=@id_masina+1
	--Client
	BEGIN TRAN
		BEGIN TRY
			IF(dbo.ValideazaClient(@cnp)=0)
			BEGIN
				RAISERROR('CNP INVALID!',14,1)
			END

			INSERT INTO Client(cnp) VALUES (@cnp)
		
			COMMIT TRAN
			SELECT 'COMMIT EFECTUAT CLIENT'
		END TRY
		BEGIN CATCH
			ROLLBACK TRAN
			SELECT 'ROLLBACK EFECTUAT CLIENT'
		END CATCH

	--masini
	BEGIN TRAN
		BEGIN TRY
			IF(dbo.ValideazaMasina(@nume,@greutate)=0)
			BEGIN
				RAISERROR('DATE INVALIDE MASINA!',14,1)
			END

			INSERT INTO Masina(nume,greutate) VALUES (@nume,@greutate)
		
			COMMIT TRAN
			SELECT 'COMMIT EFECTUAT MASINA'
		END TRY
		BEGIN CATCH
			ROLLBACK TRAN
			SELECT 'ROLLBACK EFECTUAT MASINA'
		END CATCH

	--Contract
	BEGIN TRAN 
		BEGIN TRY
			INSERT INTO Contract(id_masina,cnp) VALUES (@id_masina,@cnp)  
			COMMIT TRAN 
			SELECT 'COMMIT EFECTUAT CONTRACT' 
		END TRY
		BEGIN CATCH
			ROLLBACK TRAN 
			SELECT 'ROLLBACK EFECTUAT CONTRACT'
		END CATCH
END


--1. ADAUGARE IMPREUNA
--succes
EXEC AdaugaMasinaClientImpreuna '2786549843301','car1',1700
--insucces
EXEC AdaugaMasinaClientImpreuna '2786549843301','car1',1700

--2. ADAUGARE SEPARAT
--succes
EXEC AdaugaMasinaClientSeparat '2786549844210','car2',1390
--insucces
EXEC AdaugaMasinaClientSeparat '2786549844200','',1390