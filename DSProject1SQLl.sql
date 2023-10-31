CREATE DATABASE `project_dw` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

# From the SQL world database (Data Source 1):
CREATE TABLE `dim_country` (
  `Code` char(3) NOT NULL DEFAULT '',
  `Name` char(52) NOT NULL DEFAULT '',
  `Continent` enum('Asia','Europe','North America','Africa','Oceania','Antarctica','South America') NOT NULL DEFAULT 'Asia',
  `Region` char(26) NOT NULL DEFAULT '',
  `SurfaceArea` decimal(10,2) NOT NULL DEFAULT '0.00',
  `Population` int NOT NULL DEFAULT '0',
  `LifeExpectancy` decimal(3,1) DEFAULT NULL,
  `GNP` decimal(10,2) DEFAULT NULL,
  `GovernmentForm` char(45) NOT NULL DEFAULT '',
  `HeadOfState` char(60) DEFAULT NULL,
  PRIMARY KEY (`Code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `project_dw`.`dim_country`
(`Code`,
`Name`,
`Continent`,
`Region`,
`SurfaceArea`,
`Population`,
`LifeExpectancy`,
`GNP`,
`GovernmentForm`,
`HeadOfState`)
(
SELECT `country`.`Code`,
    `country`.`Name`,
    `country`.`Continent`,
    `country`.`Region`,
    `country`.`SurfaceArea`,
    `country`.`Population`,
    `country`.`LifeExpectancy`,
    `country`.`GNP`,
    `country`.`GovernmentForm`,
    `country`.`HeadOfState`
FROM `world`.`country`);

SELECT * FROM dim_country;

# Using the Table Data Import Wizard, I imported my API call results as a dimension table:
SELECT * FROM dim_countryapi;

# Using the Table Data Import Wizard, I imported my European Tourism CSV as a dimension table:
SELECT * FROM fact_tourism;

# Creating my official fact table (fact_tourismm) using the columns from fact_tourism (my imported CSV) and adding colums from my dimension tables:
CREATE TABLE `fact_tourismm` (
  `ï»¿Rank` int DEFAULT NULL,
  `Country` text,
  `Tourists` text,
  `Year` int DEFAULT NULL,
  `Region` char(26) NOT NULL DEFAULT '',
  `Population` int NOT NULL DEFAULT '0',
  `ID` text,
  `Code` char(3) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

# Changed the column name ï»¿Rank to Ranking:
ALTER TABLE fact_tourismm
RENAME COLUMN ï»¿Rank TO Ranking;

INSERT INTO `project_dw`.`fact_tourismm`
(`Ranking`,
`Country`,
`Tourists`,
`Year`,
`Region`,
`Population`,
`ID`,
`Code`)
SELECT `fact_tourism`.`ï»¿Rank`,
    `fact_tourism`.`Country`,
    `fact_tourism`.`Tourists`,
    `fact_tourism`.`Year`,
    `dim_country`.`Region`,
    `dim_country`.`Population`,
    `dim_countryapi`.`ID`,
    `dim_country`.`Code`
FROM project_dw.fact_tourism
INNER JOIN project_dw.dim_countryapi
ON fact_tourism.Country=dim_countryAPI.EnglishName
INNER JOIN project_dw.dim_country
ON dim_country.Name=fact_tourism.Country;

SELECT * FROM fact_tourismm;

SELECT distinct * FROM fact_tourismm;

# This deleted all the rows with NULL values (non-European countries)
DELETE FROM fact_tourismm
where fact_tourismm.Rank is Null;

# Dimension and fact tables are complete
# I do my API call and queries in Jupyter Notebook
