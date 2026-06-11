SELECT *
FROM PortfolioProject..CovidDeath
ORDER BY 1,2

-- Showing the likelihood of dying if you contract covid in Nigeria
-- Looking at total cases vs total death

SELECT country, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeath
WHERE total_cases > 0 and country = 'Nigeria'
ORDER BY 1,2

-- Showing the population percentage that have covid
-- Looking at total cases vs population

SELECT country, date, population, total_cases, (total_cases/population)*100 as PercentPopulationinfected
FROM PortfolioProject..CovidDeath
WHERE total_cases > 0 and country = 'Nigeria'
ORDER BY 1,2

-- Looking at countries with highest infection rate to population

SELECT country, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as MaxPercentPopulationinfected
FROM PortfolioProject..CovidDeath
--WHERE total_cases > 0 and country = 'Nigeria'
GROUP BY country, population
ORDER BY MaxPercentPopulationinfected desc

-- Showing country with highest death count

SELECT country, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeath
--WHERE total_cases > 0 and country = 'Nigeria'
WHERE continent is not null
GROUP BY country
ORDER BY TotalDeathCount desc

-- Let's break this down by continent
-- Showing continent with highest death count

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeath
--WHERE total_cases > 0 and country = 'Nigeria'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Global Numbers

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeath
WHERE new_cases > 0 and continent is not null
GROUP BY date
ORDER BY 1,2


SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeath
WHERE new_cases > 0 and continent is not null
--GROUP BY date
ORDER BY 1,2

--Looking at the second table

SELECT *
FROM PortfolioProject..CovidVaccinations

-- Showing People in the word that have been vaccinated

SELECT *
FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.country = vac.country
	and dea.date = vac.date


SELECT dea.continent, dea.country, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (PARTITION BY dea.country ORDER BY dea.country, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.country = vac.country
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--USE CTE

WITH PopvsVac (Continent, Country, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.country, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (PARTITION BY dea.country ORDER BY dea.country, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.country = vac.country
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- Temp table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Country nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations float,
RollingPeopleVaccinated numeric,
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.country, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (PARTITION BY dea.country ORDER BY dea.country, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.country = vac.country
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *,(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Create view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.country, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (PARTITION BY dea.country ORDER BY dea.country, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.country = vac.country
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


SELECT *
FROM  PercentPopulationVaccinated

