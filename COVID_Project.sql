SELECT *
FROM projects.COVID_DEATHS cd
WHERE continent is not NULL 
ORDER BY 3, 4


/*SELECT *
FROM projects.COVID_VACCINATIONS cd
ORDER BY 3, 4
*/

/* Select data that we are going to be using */

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM projects.COVID_DEATHS cd 
WHERE continent is not NULL
ORDER BY 1, 2

/* Looking at Total cases vs Total Deaths
 * Shows likelihood of dying if you contract covid in your country */

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM projects.COVID_DEATHS cd 
WHERE location LIKE '%spain%' 
AND continent is not NULL
ORDER BY location, STR_TO_DATE(date, '%m/%d/%Y') ASC

/* Looking at Total cases vs Population
 * Shows what percentage of population got covid */

SELECT location, date, population, total_cases, (total_cases/population)*100 as ContractedPercentage
FROM projects.COVID_DEATHS cd 
WHERE location LIKE '%states%' 
ORDER BY location, STR_TO_DATE(date, '%m/%d/%Y') ASC

/* Looking at Countries with Highest Infection Rate compared to Population */

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases)/population)*100 as ContractedPercentage
FROM projects.COVID_DEATHS cd 
/*WHERE location LIKE '%states%' */
GROUP BY location, population 
ORDER BY ContractedPercentage DESC

/* Looking at Countries with Highest Death Count per Population */

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM projects.COVID_DEATHS cd 
/*WHERE location LIKE '%states%' */
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

/* Break the world by continent 
 * Showing continents with Highest Death Count */

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM projects.COVID_DEATHS cd 
/*WHERE location LIKE '%states%' */
WHERE continent is not NULL
GROUP BY continent 
ORDER BY TotalDeathCount DESC

/* Global Numbers */

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM projects.COVID_DEATHS cd 
/* WHERE location LIKE '%states%' */
WHERE continent is not NULL
/* group by date */
ORDER BY STR_TO_DATE(date, '%m/%d/%Y') ASC

/* Looking at Total Population vs Vaccinations */

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY STR_TO_DATE(dea.date, '%m/%d/%Y') ASC) as TotalNewVaccinations
FROM projects.COVID_DEATHS dea
JOIN projects.COVID_VACCINATIONS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
AND dea.location LIKE '%states%'
ORDER BY dea.location, STR_TO_DATE(dea.date, '%m/%d/%Y') ASC

/* USE CTE */

WITH PopvsVac AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY STR_TO_DATE(dea.date, '%m/%d/%Y') ASC) as TotalNewVaccinations
FROM projects.COVID_DEATHS dea
JOIN projects.COVID_VACCINATIONS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
AND dea.location LIKE '%states%'
/*ORDER BY dea.location, STR_TO_DATE(dea.date, '%m/%d/%Y') ASC */
)
SELECT *, (TotalNewVaccinations/population)*100
FROM PopvsVac

/* Creating View to store data for later visualizations */

CREATE VIEW PercentPopulationVaccinated AS
SELECT 
    dea.continent,
    dea.location,
    STR_TO_DATE(dea.date, '%m/%d/%Y') AS Date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY STR_TO_DATE(dea.date, '%m/%d/%Y') ASC) AS TotalNewVaccinations
FROM 
    projects.COVID_DEATHS dea
JOIN 
    projects.COVID_VACCINATIONS vac ON dea.location = vac.location AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL
    AND dea.location LIKE '%states%'
ORDER BY 
    dea.location, STR_TO_DATE(dea.date, '%m/%d/%Y') ASC;
   
SELECT *
FROM PercentPopulationVaccinated;


