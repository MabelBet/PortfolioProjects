SELECT *
FROM PortfolioProject..Covid_Deaths$
ORDER BY 3, 4

SELECT *
FROM PortfolioProject.dbo.Covid_vaccinations$
WHERE continent != ' '
ORDER BY 3, 4

SELECT DISTINCT location
FROM PortfolioProject.dbo.Covid_Deaths$
WHERE continent != ' '

--Select the data that we are going to be using

SELECT location, date, total_cases, total_deaths, new_cases, population
FROM PortfolioProject.dbo.Covid_Deaths$
WHERE continent != ' '
ORDER BY 1, 2

--Looking at Total Cases Vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as Deaths_Percentage
FROM PortfolioProject..Covid_Deaths$
WHERE Location like 'col%'
ORDER BY 1, 2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid

SELECT location, date, population, total_cases, (total_cases / population)*100 as PercentOfPopulationInfected
FROM PortfolioProject..Covid_Deaths$
WHERE Location like 'col%'
ORDER BY 1, 2

--Looking at countries with highest infection rate compared to population

SELECT Location, population, MAX(total_cases) AS HighestInfectionRate, MAX((total_cases / population))*100 AS PercentOfPopulationInfected
FROM PortfolioProject.dbo.Covid_Deaths$
WHERE continent != ' '
GROUP BY population, Location
ORDER BY PercentOfPopulationInfected DESC


--Showing countries with the highest death count per population
--Converting Total_deaths into integer value

SELECT location, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..Covid_Deaths$
WHERE continent != ' '
GROUP BY location
ORDER BY TotalDeathCount DESC

--Let's break things down by continent

--Showing the continents with the highest death count per population

SELECT continent, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..Covid_Deaths$
WHERE continent != ' '
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) as CasesPerDay, SUM(CAST(new_deaths AS int)) AS DeathsPerDay,  SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100 as DeathPercentage
FROM PortfolioProject..Covid_Deaths$
WHERE continent != ''
GROUP BY date
ORDER BY 1,2

--Looking at total population vs total vaccionation


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) AS RollingPeopleVaccinated
-- , (RollingPeopleVaccinated / population) * 100
FROM PortfolioProject..Covid_Deaths$ dea
JOIN PortfolioProject..Covid_vaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent != ''
ORDER BY 2, 3

--USE CTE

WITH PopVsVac (continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) AS RollingPeopleVaccinated
-- , (RollingPeopleVaccinated / population) * 100
FROM PortfolioProject..Covid_Deaths$ dea
JOIN PortfolioProject..Covid_vaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent != ''
--ORDER BY 2, 3
)

SELECT *
FROM PopVsVac

--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations float,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
FROM PortfolioProject..Covid_Deaths$ dea
JOIN PortfolioProject..Covid_vaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent != ''
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated / Population) * 100
FROM #PercentPopulationVaccinated

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVacunated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
FROM PortfolioProject..Covid_Deaths$ dea
JOIN PortfolioProject..Covid_vaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent != ''
--ORDER BY 2, 3