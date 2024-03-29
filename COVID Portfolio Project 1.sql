SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4;

--select *
--from PortfolioProject..CovidVaccination
--order by 3, 4

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in Russia

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
AND location LIKE '%russia%'
ORDER BY 1, 2;


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
AND location LIKE '%russia%'
ORDER BY 1, 2;

-- Looking at countries with highest infection rate compared to population

SELECT location, population, max(total_cases) AS HighestInfectionCount, max((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--where location like '%russia%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

-- Showing the countries with the highest death count per population

SELECT Location, max(cast (total_deaths AS INT)) AS TotalDeathsCount
FROM PortfolioProject..CovidDeaths
--where location like '%russia%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeathsCount DESC;

-- Let's break things out by continent




-- Showing continents with the highest death count per population

SELECT Continent, max(cast (total_deaths AS INT)) AS TotalDeathsCount
FROM PortfolioProject..CovidDeaths
--where location like '%russia%'
WHERE continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathsCount DESC;



-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, SUM(cast(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--group by date	
ORDER BY 1, 2;

-- Looking at total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast (vac.new_vaccinations AS INT)) OVER (partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;


	

-- USE CTE

WITH PopvsVac (Continent, Locaton, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast (vac.new_vaccinations AS INT)) OVER (partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac;



-- TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date;
--where dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated;



--Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
--order by 2,3

SELECT *
FROM PercentPopulationVaccinated;

