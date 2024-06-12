CREATE DATABASE Linda_12;
GO
USE Linda_12;
GO

-- 1
ALTER DATABASE Linda_12 SET RECOVERY SIMPLE

CREATE TABLE BackupDesc
(ID	int IDENTITY PRIMARY KEY,
TableDescription nvarchar(300));

INSERT INTO BackupDesc VALUES ('Pirms pilnas rezerves kopēšanas');
SELECT * FROM BackupDesc;

-- pilna rezerves kopija
BACKUP DATABASE Linda_12
TO DISK = 'C:\database\backups\Linda_12.Bak' WITH FORMAT, NAME = 'Full Backup of Linda_12 database'
GO

-- backup device
USE master
EXEC sp_addumpdevice 'disk', 'Linda_12_Backup', 'C:\database\backups\Linda_12.Bak'


-- jauni dati
USE Linda_12;
GO
INSERT INTO BackupDesc VALUES ('Pēc pilnas rezerves kopēšanas');
SELECT * FROM BackupDesc;

-- pirmā diferencēta datu bāzes kopija
BACKUP DATABASE Linda_12
   TO Linda_12_Backup WITH DIFFERENTIAL
GO

-- jauni dati
INSERT INTO BackupDesc VALUES ('Pēc 1. diferencētās rezerves kopēšanas');
SELECT * FROM BackupDesc;

-- otrā diferencēta datu bāzes kopija
BACKUP DATABASE Linda_12
   TO Linda_12_Backup WITH DIFFERENTIAL
GO

-- jauni dati
INSERT INTO BackupDesc VALUES ('Pēc 2. diferencētās rezerves kopēšanas');
SELECT * FROM BackupDesc;

-- pilna atjaunošana
USE master
GO
RESTORE DATABASE Linda_12 
FROM Linda_12_Backup WITH FILE=1, RECOVERY;
GO

-- jauni dati
USE Linda_12;
GO
INSERT INTO BackupDesc VALUES ('Pēc atkopšanās no pilnas rezerves kopijas');
SELECT * FROM BackupDesc;

-- atjaunošana no pilnas un pirmās diferencētas rezerves kopijas
USE master;
GO
RESTORE DATABASE Linda_12
FROM Linda_12_Backup WITH FILE=1, NORECOVERY;
GO

RESTORE DATABASE Linda_12
FROM Linda_12_Backup WITH FILE=2, RECOVERY;
GO

USE Linda_12;
GO
SELECT * FROM BackupDesc;


-- atjaunošana no pilnas un otrās diferencētas rezerves kopijas
USE master;
GO
RESTORE DATABASE Linda_12
FROM Linda_12_Backup WITH FILE=1, NORECOVERY;
GO

RESTORE DATABASE Linda_12
FROM Linda_12_Backup WITH FILE=3, RECOVERY;
GO

USE Linda_12;
GO
SELECT * FROM BackupDesc;

-- clean up
DELETE FROM BackupDesc;
EXEC sp_dropdevice 'Linda_12_Backup', 'delfile';


------------------------------ 2

ALTER DATABASE Linda_12 SET RECOVERY FULL

EXEC sp_addumpdevice 'disk', 'Linda_12_Backup', 'C:\database\backups\Linda_12.bak'
EXEC sp_addumpdevice 'disk', 'Linda_12_Backup_Log', 'C:\database\backups\Linda_12_Log.trn'

-- jauni dati
INSERT INTO BackupDesc VALUES ('Pirms pilnas rezerves kopēšanas');
SELECT * FROM BackupDesc;

-- pilna rezerves kopija
BACKUP DATABASE Linda_12
	TO Linda_12_Backup WITH FORMAT, NAME = 'Full Backup of Linda_12 database'
GO

-- jauni dati
INSERT INTO BackupDesc VALUES ('Pēc pilnas rezerves kopēšanas');
SELECT * FROM BackupDesc;

-- diferencēta datu bāzes kopija
BACKUP DATABASE Linda_12
   TO Linda_12_Backup WITH DIFFERENTIAL
GO

-- jauni dati
INSERT INTO BackupDesc VALUES ('Pēc diferencētās rezerves kopēšanas');
SELECT * FROM BackupDesc;

--transakciju žurnāla rezerves kopija
USE master;
GO
BACKUP LOG Linda_12 TO Linda_12_Backup_Log
GO

-- jauni dati
USE Linda_12;
GO
INSERT INTO BackupDesc VALUES ('Pēc transakciju žurnāla rezerves kopijas izveides');
SELECT * FROM BackupDesc;

-- pilna atjaunošana
USE master
GO
RESTORE DATABASE Linda_12 
FROM Linda_12_Backup WITH FILE=1, RECOVERY, REPLACE;
GO

-- jauni dati
USE Linda_12
GO
INSERT INTO BackupDesc VALUES ('Pēc atkopšanās no pilnas rezerves kopijas');
SELECT * FROM BackupDesc;


-- atjaunošana no pilnas un diferencētas rezerves kopijas
USE master;
GO
RESTORE DATABASE Linda_12 FROM Linda_12_Backup WITH FILE=1, NORECOVERY, REPLACE;
RESTORE DATABASE Linda_12 FROM Linda_12_Backup WITH FILE=2, RECOVERY;
GO

USE Linda_12;
GO
SELECT * FROM BackupDesc;


-- atjaunošana no pilnas, diferencētas un transakciju žurnāla rezerves kopijas
USE master;
GO
RESTORE DATABASE Linda_12 FROM Linda_12_Backup WITH FILE=1, NORECOVERY, REPLACE;
RESTORE DATABASE Linda_12  FROM Linda_12_Backup WITH FILE=2, NORECOVERY;
RESTORE LOG Linda_12 FROM Linda_12_Backup_Log  WITH NORECOVERY;
GO
RESTORE DATABASE Linda_12 WITH RECOVERY;
GO

USE Linda_12;
GO
SELECT * FROM BackupDesc;

-- clean up
USE master;
GO
EXEC sp_dropdevice 'Linda_12_Backup', 'delfile';
EXEC sp_dropdevice 'Linda_12_Backup_Log', 'delfile';
GO
DROP DATABASE Linda_12;
