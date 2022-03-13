SELECT *
FROM PortfolioProject.DBO.CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject.DBO.CovidVaccinations
--WHERE continent is not null
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.DBO.CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Cases Vs Total Deaths in Nigeria

SELECT Location, date, total_cases, new_cases, total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.DBO.CovidDeaths
WHERE location like '%Nigeria%'
AND continent is not null
ORDER BY 1,2

-- Looking at Total Cases Vs Population

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject.DBO.CovidDeaths
--WHERE location like '%Nigeria%'
ORDER BY 1,2

-- Looking at Countries With Highest Infection Rate Vs Population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject.DBO.CovidDeaths
--WHERE location like '%Nigeria%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries With Highest Death Count per Population

SELECT Location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.DBO.CovidDeaths
--WHERE location like '%Nigeria%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Highest Death Count by Continent
--Showing Continent With Highest Death Count per Population

SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.DBO.CovidDeaths
--WHERE location like '%Nigeria%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL ANALYSIS

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_Deaths,(SUM(CAST(new_deaths as int))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject.DBO.CovidDeaths
--WHERE location like '%Nigeria%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--JOINING VACCINATION TABLE

SELECT *
FROM PortfolioProject.DBO.CovidDeaths dea
JOIN PortfolioProject.DBO.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date

--Looking at Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.DBO.CovidDeaths dea
JOIN PortfolioProject.DBO.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.DBO.CovidDeaths dea
JOIN PortfolioProject.DBO.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 As PercentagePopulationVaccinated
FROM PopvsVac

--USE TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.DBO.CovidDeaths dea
JOIN PortfolioProject.DBO.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 As PercentPopulationVaccinated
FROM #PercentPopulationVaccinated

--Creating View to Store Data for Later Visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.DBO.CovidDeaths dea
JOIN PortfolioProject.DBO.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated