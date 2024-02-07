---DATA CLEANING AND SELECTION---

-- Select the data we want to use from the deaths table
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM portfolio_project2..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

---DATA CLEANING AND SELECTION COMPLETED---

---DATA ANALYSIS START---

--Look at the number of cases versus number of deaths and 
--concatenate them into a percentage in a column of their own as the chance of dying from covid in your country
SELECT Location, date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT)/CAST(total_cases AS FLOAT)*100) death_percent
FROM portfolio_project2..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

--Look at the total cases versus the population and 
--concatenate them into a percentage in a column of their own as the chance of contracting covid in your country
SELECT Location, date, total_cases, population, (total_cases/population*100) infection_percent
FROM portfolio_project2..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

--Look at the highest amount of cases versus the country's population and 
--concatenate them into a percentage in a column of their own as the chance of contracting covid in your country
SELECT location, population,MAX(total_cases) highest_infection_count, MAX(total_cases/population*100) highest_infection_percent
FROM portfolio_project2..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY population,location
ORDER BY highest_infection_percent desc;

--Look at the highest amount of deaths for the country versus the country's population and 
--concatenate them into a percentage in a column of their own as the chance of dying from covid in your country
SELECT location, MAX(CAST(total_deaths AS INT)) highest_death_count, population, MAX(total_deaths/population*100) highest_death_percent
FROM portfolio_project2..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY population,location
ORDER BY highest_death_count desc;

--Search by Continent--

--Look at the highest amount of cases versus the continent's population and 
--concatenate them into a percentage in a column of their own as the chance of contracting covid in your continent
SELECT location, MAX(CAST(total_cases AS INT)) highest_infection_count, population, MAX(total_cases/population*100) highest_infection_percent
FROM portfolio_project2..CovidDeaths
WHERE continent IS NULL
GROUP BY population,location
ORDER BY highest_infection_count desc;

--Look at the highest amount of deaths for the country versus the continent's population and 
--concatenate them into a percentage in a column of their own as the chance of dying from covid in your continent
SELECT location, MAX(CAST(total_deaths AS INT)) highest_death_count, population, MAX(total_deaths/population*100) highest_death_percent
FROM portfolio_project2..CovidDeaths
WHERE continent IS NULL
GROUP BY population,location
ORDER BY highest_death_count desc;

---Global Statistics---

--Look at the highest amount of cases versus the world's population and 
--concatenate them into a percentage in a column of their own as the chance of contracting covid in the world
SELECT location, MAX(CAST(total_cases AS INT)) total_infection_count, population, MAX(total_cases/population*100) total_infection_percent
FROM portfolio_project2..CovidDeaths
WHERE location = 'World'
GROUP BY population,location
ORDER BY total_infection_count desc;

--Look at the highest amount of deaths for the world versus the world's population and 
--concatenate them into a percentage in a column of their own as the chance of dying from covid in in the world
SELECT location, MAX(CAST(total_deaths AS INT)) total_death_count, population, MAX(total_deaths/population*100) total_death_percent
FROM portfolio_project2..CovidDeaths
WHERE location = 'World'
GROUP BY population,location
ORDER BY total_death_count desc;

--Look at the total number of cases versus the total number of deaths to find Covid's lethality rate on a global scale.
--Store the data in its own column as the chance of chance of dying after getting covid in in the world
SELECT location, population, MAX(CAST(total_deaths AS INT)) total_death_count, MAX(CAST(total_cases AS INT)) total_infection_count, 
MAX((CAST(total_deaths AS FLOAT)/CAST(total_cases AS FLOAT))*100) total_death_percent
FROM portfolio_project2..CovidDeaths
WHERE location = 'World'
GROUP BY population,location,total_cases,total_deaths
ORDER BY total_death_count desc;

---BRING IN THE VACCINE DATA---

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations as BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.date) total_Vaccinated
FROM portfolio_project2..CovidDeaths dea
JOIN portfolio_project2..CovidVaccinations vac
    ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- Use a CTE to compare number of vaccinated to populations/rates as needed

WITH VaccdPopulation (continent, location, date, population, new_vaccinations, total_vaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations as BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.date) total_Vaccinated
FROM portfolio_project2..CovidDeaths dea
JOIN portfolio_project2..CovidVaccinations vac
    ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL)

SELECT *, (total_vaccinated/population*100) percent_vaccinated --WARNING: Dataset does not take into account boosters, number of vaccines may be higher than population for some areas
FROM VaccdPopulation;

-- Use a Temp table to compare number of vaccinated to populations/rates as needed

DROP TABLE IF EXISTS #VaccinatedPopulationPercentage

CREATE TABLE #VaccinatedPopulationPercentage (
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
total_Vaccinated numeric
)

INSERT INTO #VaccinatedPopulationPercentage

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations as BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.date) total_Vaccinated
FROM portfolio_project2..CovidDeaths dea
JOIN portfolio_project2..CovidVaccinations vac
    ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *, (total_vaccinated/population*100) percent_vaccinated --WARNING: Dataset does not take into account boosters, number of vaccines may be higher than population for some areas
FROM #VaccinatedPopulationPercentage;

-- Create view for data storage to help with later visualizations 

CREATE VIEW VaccinatedPopulationPercentage AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations as BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.date) total_Vaccinated,
	SUM(CAST(vac.new_vaccinations as BIGINT)) OVER (PARTITION BY dea.continent ORDER BY dea.date) total_Vaccinated_byCont
FROM portfolio_project2..CovidDeaths dea
JOIN portfolio_project2..CovidVaccinations vac
    ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

-- Create Table for total deaths, cases, and lethality percentage for Covid per country

CREATE VIEW DeathsVSCases AS
SELECT continent, location, date, population, 
	MAX(CAST(total_deaths AS INT)) highest_death_count, MAX(total_deaths/population*100) highest_death_percent
FROM portfolio_project2..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent, date, location, population;


-- Create Table for total deaths, cases, and lethality percentage for Covid in your Continent

CREATE VIEW ContinentalCovidData AS
SELECT location, MAX(CAST(total_deaths AS INT)) highest_death_count, population, MAX(total_deaths/population*100) highest_death_percent,

FROM portfolio_project2..CovidDeaths
WHERE continent IS NULL
GROUP BY population,location;


-- Create Table for total deaths, cases, and lethality percentage for Covid Globally

CREATE VIEW GlobalCovidData AS
SELECT continent, location, population, MAX(CAST(total_deaths AS INT)) total_death_count, MAX(CAST(total_cases AS INT)) total_infection_count, 
MAX((CAST(total_deaths AS FLOAT)/CAST(total_cases AS FLOAT))*100) total_death_percent
FROM portfolio_project2..CovidDeaths
WHERE location = 'World'
GROUP BY population,location,continent,total_cases,total_deaths;



--- DATA ANALYSIS COMPLETED ---