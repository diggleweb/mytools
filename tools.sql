/* MYSQL PROCEDURE TOOLS
 * Author: Ivan Cachicatari
 */

CREATE DATABASE IF NOT EXISTS tools;
USE tools;


/* PROCEDURE: sp_status
 * Author: Ivan Cachicatari
 * Date: Nov 30 2012
 * Before use it please read:
 * http://en.latindevelopers.com/ivancp/2012/a-better-show-table-status/
 */


DELIMITER $$
DROP PROCEDURE IF EXISTS `sp_status` $$
CREATE PROCEDURE `sp_status`(dbname VARCHAR(50))
BEGIN 
-- Obtaining tables and views
(
    SELECT 
     TABLE_NAME AS `Table Name`, 
     ENGINE AS `Engine`,
     TABLE_ROWS AS `Rows`,
     CONCAT(
        (FORMAT((DATA_LENGTH + INDEX_LENGTH) / POWER(1024,2),2))
        , ' Mb')
       AS `Size`,
     TABLE_COLLATION AS `Collation`
    FROM information_schema.TABLES
    WHERE TABLES.TABLE_SCHEMA = dbname
          AND TABLES.TABLE_TYPE = 'BASE TABLE'
)
UNION
(
    SELECT 
     TABLE_NAME AS `Table Name`, 
     '[VIEW]' AS `Engine`,
     '-' AS `Rows`,
     '-' `Size`,
     '-' AS `Collation`
    FROM information_schema.TABLES
    WHERE TABLES.TABLE_SCHEMA = dbname 
          AND TABLES.TABLE_TYPE = 'VIEW'
)
ORDER BY 1;
-- Obtaining functions, procedures and triggers
(
    SELECT ROUTINE_NAME AS `Routine Name`, 
     ROUTINE_TYPE AS `Type`,
     '' AS `Comment`
    FROM information_schema.ROUTINES
    WHERE ROUTINE_SCHEMA = dbname
    ORDER BY ROUTINES.ROUTINE_TYPE, ROUTINES.ROUTINE_NAME
)
UNION
(
    SELECT TRIGGER_NAME,'TRIGGER' AS `Type`, 
    concat('On ',EVENT_MANIPULATION,': ',EVENT_OBJECT_TABLE) AS `Comment`
    FROM information_schema.TRIGGERS
    WHERE EVENT_OBJECT_SCHEMA = dbname
)
ORDER BY 2,1;
END$$
DELIMITER ;


/* PROCEDURE: sp_overview
 * Author: Ivan Cachicatari
 * Date: Feb 25 2012
 * Before use it please read:
 * http://en.latindevelopers.com/ivancp/2012/mysql-get-disk-usage-of-all-databases/
 */

 
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_overview$$
CREATE PROCEDURE sp_overview()
BEGIN
 
    SELECT s.SCHEMA_NAME AS `Database`, s.DEFAULT_CHARACTER_SET_NAME AS `Charset`,
        COUNT(t.TABLE_NAME) AS `Tables`,
 
        (SELECT COUNT(*) FROM information_schema.ROUTINES AS r
            WHERE r.routine_schema = s.SCHEMA_NAME) AS `Routines`,
 
         round(SUM(t.DATA_LENGTH + t.INDEX_LENGTH) / 1048576 ,1) AS `Size Mb`
 
        FROM information_schema.SCHEMATA AS s
            LEFT JOIN information_schema.TABLES t ON s.schema_name = t.table_schema
        WHERE s.SCHEMA_NAME NOT IN ('information_schema', 'performance_schema')
 
    GROUP BY s.SCHEMA_NAME;
END$$
DELIMITER ;


